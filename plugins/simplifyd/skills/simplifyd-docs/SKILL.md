---
name: simplifyd-docs
description: Use this skill when the user asks questions about Simplifyd Cloud features, capabilities, plans, pricing, how things work, what regions are available, what databases are supported, how billing works, or any general "what can Simplifyd Cloud do?" questions.
---

# Simplifyd Cloud Documentation

Answer questions about Simplifyd Cloud's features, architecture, and capabilities.

## When to Use

- User asks "what is Simplifyd Cloud?"
- User asks about features: "does it support X?", "can I do Y?"
- User asks about pricing or plans
- User asks about supported regions, databases, or runtime environments
- User asks how something works (billing, deployments, networking, etc.)
- User is evaluating Simplifyd Cloud vs another platform

## When NOT to Use

- User wants to perform an action (deploy, create service, etc.) → use the appropriate action skill
- User has a specific error to debug → check logs or context first

---

## What is Simplifyd Cloud?

Simplifyd Cloud is a cloud infrastructure management platform that lets teams deploy and manage containerized applications and managed databases. It is organized around a hierarchy of:

```
Workspace → Project → Environment → Service → Deployment
```

- **Workspace** — The top-level organizational unit (team or organization)
- **Project** — A collection of related services (e.g., "backend", "frontend")
- **Environment** — An isolated runtime context within a project (e.g., production, staging)
- **Service** — A running workload: Docker container, managed PostgreSQL database, or managed Redis instance
- **Deployment** — A specific instance/version of a service that was deployed

---

## Service Types

### Docker Services

Run any Docker image as a service:

- Bring your own Docker image (public registry or Docker Hub)
- Update CPU, memory, and image configuration
- Each service gets a managed DNS name (FQDN)

### PostgreSQL Databases

Managed PostgreSQL database services:

- Fully managed — no manual setup
- Automatically provisioned within the environment
- Connection string provided as a service variable
- Isolated per environment (production DB separate from staging DB)

### Redis

Managed Redis services:

- Supports standalone, replication, and cluster modes
- Optional storage sizing
- Replica count for Redis replication/cluster layouts

---

## Infrastructure & Networking

### Ingress & Domains

Each service can have one or more ingress points:

- **Protocol**: HTTP/HTTPS
- **Port**: The container port to expose
- **Automatic FQDN**: Simplifyd assigns a DNS name automatically
- **Custom Domain**: Bring your own domain (custom FQDN)

---

## Resource Configuration

Services are configured with:

| Resource  | Flag        | Description                      |
|-----------|-------------|----------------------------------|
| CPU       | `--vcpus`   | CPU in millicores                |
| Memory    | `--memory`  | RAM in MiB                       |
| Storage   | `--storage` | Storage in GB for Postgres/Redis |
| Mode      | `--mode`    | Database/cache mode              |
| Replicas  | `--replicas`| Redis replicas                   |

CPU, memory, and image changes are made with `edge service update`. Storage, mode, and replicas are creation-time options for database/cache services.

---

## Variables & Configuration

Two scopes for environment variables:

- **Environment-level**: Shared by all services in an environment (e.g., a shared `DATABASE_URL`)
- **Service-level**: Scoped to a single service (e.g., a service-specific `PORT`)

Static config mounts are managed separately with `edge service config add/update/delete` and mount file content inside a service container.

---

## Authentication & Access

- **User auth**: Email + password login via the CLI (`edge auth login`) or web console
- **Google OAuth**: Supported via the web console
- **API tokens**: Long-lived tokens for CI/CD pipelines and automation
  - Created per environment
  - Used via `--token` flag, `CLOUD_TOKEN` env var, or stored login config

### Workspace Members

Workspaces support multiple members with role-based access. Members can be added by email.

---

## CLI (`edge`)

The Simplifyd Cloud CLI is named `edge`. Key commands:

| Command                    | Description                          |
|----------------------------|--------------------------------------|
| `edge auth login`          | Authenticate                         |
| `edge status`              | Show current context                 |
| `edge link`                | Link directory to workspace/project/env |
| `edge workspace list`      | List workspaces                      |
| `edge project list`        | List projects                        |
| `edge env list`            | List environments                    |
| `edge service list`        | List services                        |
| `edge service create`      | Create a service                     |
| `edge service update`      | Update name, CPU, memory, or image   |
| `edge service config add`  | Add a static config mount            |
| `edge service shell <svc>` | Open an interactive service shell    |
| `edge registry push`       | Push a local Docker image to sdcr.io |
| `edge deploy up <svc>`     | Deploy a service                     |
| `edge deploy down <svc>`   | Stop a service                       |
| `edge deploy logs <svc>`   | Stream service logs                  |
| `edge variables list`      | List environment variables           |
| `edge variables set KEY=V` | Set a variable                       |
| `edge token create`        | Create an API token                  |

Global flags available on all commands:
- `--workspace`, `--project`, `--env` — Override active context
- `--json` — Machine-readable JSON output
- `--token` — Use a specific API token

Context resolution order is command flags, `.edge.json`, then `~/.simplifyd/config.json`. Token resolution order is `--token`, `CLOUD_TOKEN`, then stored login config.

---

## Web Console

The Simplifyd Cloud web console is at `https://console.cloud.simplifyd.com`. It provides:

- Visual dashboard for all resources
- Deployment history and status
- Log viewer
- Billing and usage overview

---

## Admin Console

Administrators have access to a separate admin dashboard for platform-level management.

---

## Payments & Billing

Simplifyd Cloud supports multiple payment gateways:

- **Stripe** — Credit card payments
- **Paystack** — African market payment processing
- **Flutterwave** — Pan-African payments

Billing is based on resource usage (CPU, memory, services, deployments).

---

## How Deployments Work

1. A service is created with a Docker image and resource config
2. `edge deploy up <svc>` triggers a new deployment
3. The platform pulls the image and schedules it
4. The deployment transitions: `pending` → `running`
5. Logs stream via SSE (Server-Sent Events)
6. `edge deploy down <svc>` stops the running deployment

Redeployments (same image, updated config or variables) use the same flow.

---

## Composability Tip

Typical workflow for a new service:

```bash
# 1. Set context
edge workspace use my-team
edge project use backend
edge env use production

# 2. Create service
edge service create --name api --type docker --image node:20

# 3. Set variables
edge variables set NODE_ENV=production DATABASE_URL=postgres://...

# 4. Deploy, approving pending changes if needed in automation
edge deploy up api --yes

# 5. Watch logs
edge deploy logs api
```
