---
name: service
description: Use this skill when the user wants to list, create, view, update, delete, connect to, configure, or share services privately across Simplifyd Cloud projects. Triggers on "list services", "create service", "new service", "what services do I have", "delete service", "scale service", "update service", "service details", "service shell", "private service access", "cross-project access", "share database with another project", "add config file", "mount config", "service changeset", "add a postgres database", "add redis", "deploy an nginx container", or similar.
allowed-tools: Bash(edge:*)
---

# Service Management

Create, list, inspect, update, configure, connect to, and delete services within a Simplifyd Cloud environment.

## When to Use

- User asks "what services do I have?" or "list my services"
- User wants to create a Docker, PostgreSQL, or Redis service
- User wants service details, pending changes, ingress, config mounts, or shell access
- User wants to update a service name, CPU, memory, or Docker image
- User wants to delete a service

## When NOT to Use

- User wants to deploy/redeploy a service -> use `deploy` skill
- User wants deployment logs -> use `logs` skill
- User wants environment variables or secrets -> use `variables` skill
- User wants to push an image to the workspace registry -> use `registry` skill

## Prerequisites

Workspace, project, and environment must all be set:

```bash
edge status --json
```

If any are missing, set them first using the `workspace`, `project`, or `environment` skill.

The CLI accepts service names or slugs for most service operations and resolves names to slugs when authenticated.

## List Services

```bash
edge service list --json
```

Present the returned services as a compact table with name, slug, type, status, and image/database details when present.

## Get Service Details

```bash
edge service get <svc-slug-or-name> --json
```

Use this before risky changes, before deleting, or when the user asks for current configuration.

## Service Types

| Type | Use | Important flags |
|---|---|---|
| `docker` | Run a container image | `--image`, optional `--tag` |
| `postgres` | Managed PostgreSQL | optional `--storage`, `--mode standalone|replication` |
| `redis` | Managed Redis | optional `--storage`, `--mode standalone|replication|cluster`, `--replicas` |

## Create Service

### Docker Container

```bash
edge service create --name api --type docker --image nginx --tag latest
```

The image can include a tag, such as `nginx:latest`, or use `--tag` separately.

### PostgreSQL Database

```bash
edge service create --name db --type postgres --storage 20 --mode standalone
```

### Redis

```bash
edge service create --name cache --type redis --storage 10 --mode standalone
```

For Redis replication or cluster modes, include replicas:

```bash
edge service create --name cache --type redis --mode replication --replicas 2
```

### Create Flags Reference

| Flag | Description |
|---|---|
| `--name` | Service name, required |
| `--type` | `docker`, `postgres`, or `redis`, required |
| `--image` | Docker image, for Docker services |
| `--tag` | Docker image tag |
| `--storage` | Storage in GB, for Postgres/Redis |
| `--mode` | `standalone`, `replication`, or Redis `cluster` |
| `--replicas` | Redis replicas, 1-10 |

## Update Service

Only one update field may be changed per command:

```bash
edge service update api --name api-v2
edge service update api --vcpus 500
edge service update api --replicas 2
edge service update api --memory 1024
edge service update api --image sdcr.io/my-registry/api:2.0
```

`--vcpus` is in millicores. `--replicas` supports 1-10 replicas for Docker services. `--memory` is in MiB. After changing image, replica count, or resource settings, deploy with `edge deploy up <svc>`.

## Delete Service

```bash
edge service delete <svc-slug-or-name>
```

Use `--force` only when the user has clearly confirmed deletion:

```bash
edge service delete <svc-slug-or-name> --force
```

This permanently deletes the service and its deployments. Confirm with the user before running.

## Manage Ingress

Add ingress:

```bash
edge service ingress add api --protocol HTTP --port 8080
edge service ingress add api --protocol gRPC --port 50051 --custom-fqdn grpc.example.com
edge service ingress add api --protocol TCP --port 5432
```

For TCP/UDP ingress, optionally restrict which client IPs may connect with repeatable `--allow` flags (IPs or CIDRs; bare IPs are treated as /32). Without `--allow`, the port is open to the whole internet:

```bash
edge service ingress add api --protocol TCP --port 5432 --allow 203.0.113.7 --allow 198.51.100.0/24
```

Set or replace the IP allowlist on an existing TCP/UDP ingress port (applies to the live LoadBalancer immediately, no redeploy needed). Use `--clear` to remove the allowlist and open the port to all IPs:

```bash
edge service ingress allow api <ingress-slug> --allow 203.0.113.7 --allow 198.51.100.0/24
edge service ingress allow api <ingress-slug> --clear
```

Recommend an allowlist whenever a user exposes a database or other sensitive service over TCP — especially for production data. Find the ingress slug and current allowlist (`allowed_source_ranges`) via `edge service get <svc> --json`.

Delete ingress:

```bash
edge service ingress delete api <ingress-slug>
```

There is no `edge service ingress list` command in this CLI; use `edge service get <svc> --json` to inspect ingress details if they are included in the service response.

## Manage Cross-Project Private Access

Use private access grants when a service in one project must be reachable from services in another project in the same workspace. Do not create public TCP ingress for this workflow.

Inspect the destination service and existing grants first:

```bash
edge service get <destination-service> --json
edge service access list <destination-service> --json
```

Resolve the consumer project slug with `edge project list --json`, then grant one explicit port and protocol:

```bash
edge service access grant <destination-service> <consumer-project-slug> --protocol TCP --port 5432 --json
```

The change applies to a running service without a redeploy. Give the consumer the `private_hostname` returned by `edge service get`; credentials and secret distribution remain separate.

Revoke by immutable grant slug:

```bash
edge service access revoke <destination-service> <grant-slug>
```

Before granting or revoking, confirm the destination service, consumer project, protocol, and port with the user. Both projects must belong to the active workspace. Same-project connectivity is already enabled and needs no grant.

## Manage Static Config Mounts

Use service config mounts for file content that should be mounted inside the container, such as config files or certificates.

Add inline content:

```bash
edge service config add api --name app-config --mount-path /app/config.json --content '{"debug":false}'
```

Add content from a local file:

```bash
edge service config add api --name nginx-conf --mount-path /etc/nginx/nginx.conf --file ./nginx.conf
```

Update a config mount:

```bash
edge service config update api <config-slug> --name nginx-conf --mount-path /etc/nginx/nginx.conf --file ./nginx.conf
```

Delete a config mount:

```bash
edge service config delete api <config-slug>
edge service config delete api <config-slug> --force
```

`--content` and `--file` are mutually exclusive. Deploy after config changes if the running service needs the new content.

## View Pending Changes

```bash
edge service changeset api --json
edge service changeset api
```

In interactive mode, `edge service changeset <svc>` can approve/deploy, discard, or exit. For non-interactive approval:

```bash
edge service changeset api --yes
```

## Open a Service Shell

```bash
edge service shell api
```

This opens an interactive shell in a running service container. Use only when the user wants an interactive session and a terminal is available.

## Error Handling

### No Context Set

```
Error: no workspace/project/environment set
```

Use `status` skill to check context, then set missing values.

### Service Not Found

```
Error: service not found
```

Run `edge service list --json` to find the service name or slug.

### Invalid Type

```
Error: --type is required (docker, postgres, or redis)
```

Specify one of the supported service types.

### Multiple Update Fields

```
Error: only one of --name, --vcpus, --memory, or --image may be set at a time
```

Run separate `edge service update` commands for each change.

## Composability

- Deploy after creation or updates with `deploy` skill
- Set environment variables with `variables` skill
- Push private images with `registry` skill
- Watch logs after deploy with `logs` skill
