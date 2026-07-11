---
name: status
description: Use this skill when the user asks about their current Simplifyd Cloud context, "what's my current workspace/project/environment", "am I logged in", "edge status", "show me what's linked", or wants a quick health check before other operations.
allowed-tools: Bash(edge:*), Bash(which:*)
---

# Simplifyd Cloud Status

Check the current CLI context — authenticated user, active workspace, project, and environment.

## When to Use

- User asks "what workspace am I in?", "what's my current project?", "am I logged in?"
- Before any Simplifyd Cloud operation to verify context is set
- User says "edge status" or "show me the current context"
- Troubleshooting missing context errors

## When NOT to Use

- User wants to list all workspaces → use `workspace` skill
- User wants to list services or deployments → use `service` or `deploy` skill
- User wants to change the active context → use `workspace`, `project`, or `environment` skill

## Check Status

First verify the CLI is installed:

```bash
command -v edge
```

Then check status:

```bash
edge status --json
```

## Handling Errors

### CLI Not Installed

If `command -v edge` fails:

> The Simplifyd Cloud CLI (`edge`) is not installed.
>
> Install it with:
> ```
> # Download a release binary, or run the install script from the repo:
> # https://github.com/simplifyd-systems/cli/releases
> sh install.sh
> ```
> Then authenticate: `edge auth login`

### Not Authenticated

If `edge auth whoami` fails or `edge status` shows no auth:

> Not logged in to Simplifyd Cloud. Run:
> ```
> edge auth login
> ```

### No Context Set

If workspace/project/env fields are empty:

> No workspace/project/environment context is set.
>
> Options:
> - Link the current directory: `edge link`
> - Set active defaults: `edge workspace use <slug>`, `edge project use <slug>`, `edge env use <slug>`

## Presenting Status

Parse the JSON output and present clearly:

```
Auth: authenticated (user@example.com)
API: https://api.cloud.simplifyd.com

Active Context:
  Workspace:   my-team
  Project:     backend
  Environment: production

Linked (.edge.json):
  Workspace:   my-team
  Project:     backend
  Environment: production
```

Key fields from `edge status --json`:
- `auth` — "authenticated" or "not logged in"
- `api_url` — the API endpoint in use
- `active_workspace`, `active_project`, `active_env` — from config defaults
- `link_workspace`, `link_project`, `link_env` — from `.edge.json` in current directory tree

Token resolution order is `--token`, then `CLOUD_TOKEN`, then `~/.simplifyd/config.json`.

## Composability

- **Log in**: Use `auth` skill
- **Set workspace context**: Use `workspace` skill
- **Set project context**: Use `project` skill
- **Set environment context**: Use `environment` skill
- **Link directory**: Run `edge link`
