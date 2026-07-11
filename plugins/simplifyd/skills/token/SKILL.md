---
name: token
description: Use this skill when the user wants to create, list, or delete API tokens on Simplifyd Cloud. Triggers on "create token", "API token", "CI/CD token", "access token", "list tokens", "delete token", "rotate token", or "I need a token for my pipeline".
allowed-tools: Bash(edge:*)
---

# API Token Management

Create, list, and delete API tokens for programmatic access to Simplifyd Cloud.

## When to Use

- User wants a token for CI/CD pipelines or automation
- User wants to list existing tokens
- User wants to revoke/delete a token
- User needs to rotate a compromised token

## When NOT to Use

- User wants to authenticate interactively → use `auth` skill (`edge auth login`)
- User wants to set environment variables → use `variables` skill

## Prerequisites

Must be authenticated:

```bash
edge auth whoami --json
```

Tokens are user-scoped and tied to an environment. Have the environment ID or context set.

## List Tokens

```bash
edge token list --json
```

Returns: `id`, `slug`, `name`, `env_id`, `created_at`.

> Note: The full token value is **not** shown after creation — it is only returned once at creation time.

Present as a table:

```
NAME        SLUG        ENV ID          CREATED
ci-prod     ci-prod     env-abc123      2024-03-01
staging-ci  staging-ci  env-def456      2024-02-15
```

## Create Token

```bash
edge token create "CI Production"
```

To scope the token to a specific environment:

```bash
edge token create "CI Production" --env production
```

**The token value is shown only once at creation.** Save it immediately — it cannot be retrieved later.

Store the token securely (e.g., in GitHub Actions Secrets, a password manager, or a secrets manager).

### Use a Token in CI/CD

**Environment variable (recommended):**

```bash
export CLOUD_TOKEN=<token-value>
edge service list  # automatically uses CLOUD_TOKEN
```

**GitHub Actions example:**

```yaml
- name: Deploy to Simplifyd Cloud
  env:
    CLOUD_TOKEN: ${{ secrets.SIMPLIFYD_TOKEN }}
  run: |
    edge deploy up api
```

**Per-command:** `--token` takes precedence over `CLOUD_TOKEN` and stored login config.

```bash
edge deploy up api --token <token-value>
```

## Delete Token

```bash
edge token delete <token-slug>
```

Use the `slug` field from `edge token list --json`.

**Token rotation flow:**

1. Create a new token: `edge token create "CI Production v2"`
2. Update the secret in your CI/CD system with the new value
3. Delete the old token: `edge token delete <old-slug>`

## Error Handling

### Token Not Shown Again

If the user missed copying the token at creation:

> The token value is only shown once at creation time. You'll need to delete the existing token and create a new one.

### Token Not Found

```
Error: token not found
```

→ Run `edge token list --json` to find the correct token slug.

### Unauthorized

If operations fail with a token:
- Verify the token is not expired
- Confirm the token has access to the correct workspace/project/env
- Try re-authenticating: `edge auth login`

## Composability

- **After creating a token**: Store in CI/CD secrets and test with `edge status --token <value>`
- **For per-service access**: Scope the token to a specific environment using `--env` context
