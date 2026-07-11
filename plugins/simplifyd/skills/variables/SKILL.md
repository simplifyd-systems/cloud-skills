---
name: variables
description: Use this skill when the user wants to list, set, or delete environment variables or secrets on Simplifyd Cloud. Triggers on "add env var", "set variable", "list variables", "env vars", "environment variables", "secrets", "set DATABASE_URL", "delete variable", "what variables are set", or "configure my service with secrets".
allowed-tools: Bash(edge:*)
---

# Variables

Manage environment variables for environments and services on Simplifyd Cloud.

## When to Use

- User wants to list variables: "what variables are set?", "show env vars"
- User wants to add or update a variable: "set DATABASE_URL", "add API_KEY"
- User wants to delete a variable: "remove OLD_VAR", "delete that secret"
- User wants to configure a service with secrets or connection strings
- Deployment logs show "missing environment variable" errors

## When NOT to Use

- User wants to switch environments → use `environment` skill
- User wants to deploy after setting variables → use `deploy` skill

## Variable Scopes

Simplifyd Cloud has two variable scopes:

| Scope | Description | Flag |
|-------|-------------|------|
| **Environment-level** | Shared across all services in the environment | (no `--service` flag) |
| **Service-level** | Only available to a specific service | `--service <slug>` |

Service-level variables take precedence over environment-level ones with the same name.

## Prerequisites

Workspace, project, and environment must be set:

```bash
edge status --json
```

## List Variables

### Environment-level variables

```bash
edge variables list --json
```

Returns: `id`, `name`, `value`.

### Service-level variables

```bash
edge variables list --service api --json
```

Present as a table:

```
NAME            VALUE              SCOPE
DATABASE_URL    postgres://...     environment
API_KEY         sk-live-...        environment
PORT            8080               service: api
NODE_ENV        production         environment
```

**Note:** Sensitive values are shown as-is. Handle with care — avoid printing them to shared terminals.

## Set Variables

### Set environment-level variable

```bash
edge variables set KEY=VALUE
edge variables set NODE_ENV=production
edge variables set DATABASE_URL="postgres://user:pass@host:5432/db"
```

### Set multiple variables at once

```bash
edge variables set NODE_ENV=production API_URL=https://api.example.com PORT=3000
```

### Set service-level variable

```bash
edge variables set --service api PORT=8080
edge variables set --service worker CONCURRENCY=5
```

### Value Quoting

For values with spaces or special characters, quote the value:

```bash
edge variables set GREETING="Hello World"
edge variables set DB_URL="postgres://user:p@ssw0rd!@host/db"
```

## Delete Variables

```bash
edge variables delete OLD_KEY
```

`delete` accepts one variable slug/name at a time. Loop through multiple variables if the user asks to delete several.

For service-level deletion:

```bash
edge variables delete --service api OLD_PORT
```

## Common Variable Patterns

### Database connection

```bash
edge variables set DATABASE_URL="postgres://user:password@host:5432/dbname?sslmode=require"
```

### API secrets

```bash
edge variables set \
  STRIPE_SECRET_KEY=sk_live_... \
  SENDGRID_API_KEY=SG.... \
  JWT_SECRET=your-secret-here
```

### Runtime config

```bash
edge variables set \
  NODE_ENV=production \
  PORT=8080 \
  LOG_LEVEL=info
```

## After Setting Variables

Variables take effect on the next deployment. Redeploy the service:

```bash
edge deploy up <svc-slug>
```

## Error Handling

### Invalid Format

```
Error: invalid format "MYVAR" — use KEY=VALUE
```

→ Make sure you pass the variable as `KEY=VALUE` format.

### Variable Not Found (on delete)

```
Error: variable not found
```

→ Run `edge variables list --json` to check the exact variable name.

### Context Not Set

```
Error: workspace/project/environment is required
```

→ Use `status` skill to check and set context.

## Decision Flow

```
User mentions variables
        │
  What do they want?
        │
   ┌────┼────┬────┐
 List  Set  Delete Multi-set
   │    │     │      │
 Show  Run  Run    Loop
 table set  delete through
       cmd   cmd   KEY=VALUE
                   pairs
```

## Composability

- **After setting variables**: Redeploy with `deploy` skill
- **Check logs after deploy**: Use `logs` skill to confirm vars are picked up
- **Service-level config**: Use `--service <slug>` flag to scope variables
