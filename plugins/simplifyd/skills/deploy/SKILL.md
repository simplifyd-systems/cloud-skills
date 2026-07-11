---
name: deploy
description: Use this skill when the user wants to deploy, redeploy, stop, or undeploy a service on Simplifyd Cloud. Triggers on "deploy", "redeploy", "start service", "stop service", "take down", "deploy up", "deploy down", "undeploy", "list deployments", "deployment history", or "deployment status".
allowed-tools: Bash(edge:*)
---

# Deployments

Deploy, redeploy, stop services, and view deployment history on Simplifyd Cloud.

## When to Use

- User wants to deploy a service: "deploy", "start", "ship", "go live"
- User wants to redeploy: "redeploy", "restart", "re-deploy"
- User wants to stop a service: "stop", "take down", "undeploy", "deploy down"
- User wants to check deployment history: "list deployments", "deployment history"
- User asks about deployment status

## When NOT to Use

- User wants to view streaming logs → use `logs` skill
- User wants to create a new service → use `service` skill
- User wants to set environment variables → use `variables` skill

## Prerequisites

Workspace, project, environment, and service slug must all be known:

```bash
edge status --json
```

If context is missing, set it first. If the service slug is unknown:

```bash
edge service list --json
```

## Deploy a Service (Up)

Deploys or redeploys a service. The CLI automatically tries a new deployment first, then falls back to redeployment:

```bash
edge deploy up <svc-slug>
```

If the service has pending changes, the CLI shows the changeset and asks for confirmation in interactive mode. In non-interactive automation, pass `--yes` / `-y` to approve the pending changeset:

```bash
edge deploy up <svc-slug> --yes
```

Returns: `id`, `slug`, `status`, `service_id`, `created_at`.

**Example:**

```bash
edge deploy up api
```

Expected output:
```
Deployment started: dep-abc123 (status: pending)
```

After starting, use the `logs` skill to watch progress.

## Stop a Service (Down)

Removes the active deployment, stopping the service:

```bash
edge deploy down <svc-slug>
```

**Caution:** This stops the running service. Confirm with the user before running.

## List Deployment History

```bash
edge deploy list <svc-slug> --json
```

Returns deployment records for the current service context, including: `id`, `slug`, `status`, `service_id`, `created_at`, `updated_at`.

**To specify a service explicitly:**

```bash
edge deploy list api --json
```

> Note: The `deploy list` command uses the current workspace/project/env context and accepts an optional service slug/name.

Present as a table:

```
SLUG          STATUS     SERVICE   CREATED
dep-abc123    running    api       2024-03-01 10:00
dep-def456    stopped    api       2024-02-28 09:00
dep-ghi789    failed     api       2024-02-27 08:00
```

## Deployment Statuses

| Status    | Meaning                                        |
|-----------|------------------------------------------------|
| `pending` | Deployment queued, not yet started             |
| `running` | Deployed and running                           |
| `stopped` | Service stopped (via deploy down)              |
| `failed`  | Deployment failed                              |

## Decision Flow

```
User says "deploy"
        │
  Check context set?
        │
   ┌────┴────┐
  Yes       No
   │         │
  Run      Set context
 deploy up  first
   │
 Show dep
  slug +
  status
   │
 Suggest
  checking
  logs
```

## After Deploying

Use the `logs` skill to stream deployment output:

```bash
edge deploy logs <svc-slug>
```

Or check deployment history:

```bash
edge deploy list --json
```

## Error Handling

### Service Slug Required

```
Error: service slug is required
```

→ Pass the service slug as an argument: `edge deploy up <slug>`.
→ Or list services first: `edge service list --json`

### No Deployments Found

```
Error: no deployments found for service <slug>
```

→ The service has never been deployed. Run `edge deploy up <slug>`.

### Context Not Set

```
Error: workspace/project/environment is required
```

→ Use `status` skill to verify and set context.

### Deploy Failed

If the deployment shows `failed` status:

1. Check logs: use `logs` skill
2. Verify the Docker image is correct: `edge service get <slug> --json`
3. Check environment variables: `edge variables list --json`

### Pending Changeset Requires Confirmation

```
Error: pending changeset requires confirmation — re-run with --yes to auto-approve
```

Review pending changes first:

```bash
edge service changeset <svc-slug>
```

Then deploy with `--yes` only when the user or automation flow has clearly approved those changes.

## Composability

- **Create a service first**: Use `service` skill
- **Set env vars before deploy**: Use `variables` skill
- **Watch logs after deploy**: Use `logs` skill
- **Stop a running service**: `edge deploy down <slug>`
