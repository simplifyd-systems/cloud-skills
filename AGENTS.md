# Simplifyd Cloud Skills

Agent Skills for [Simplifyd Cloud](https://console.cloud.simplifyd.com). Use these skills to work with Simplifyd Cloud through the `edge` CLI from supported developer tools.

## Skills

Skills are invoked by supported tools based on user intent matching the skill description. Each skill lives in `plugins/simplifyd/skills/{name}/SKILL.md`.

## Runtime Model

Skills use the Simplifyd Cloud CLI (`edge`):

**CLI** — The `edge` command. Covers all resource operations (workspaces, projects, environments, services, deployments, variables, tokens). Always use `--json` flag for parseable output.

### Authentication

Token location: `~/.simplifyd/config.json` → `token`

The CLI reads auth state from this file automatically. Skills check for authentication with `edge auth whoami --json` before performing operations.

### Context Resolution

The `edge` CLI resolves workspace/project/environment context in this priority order:

1. `--workspace`, `--project`, `--env` flags
2. `.edge.json` file in the current directory (or any parent)
3. `~/.simplifyd/config.json` active defaults

Skills check context with `edge status --json` before operations.

Token resolution order is `--token`, then `CLOUD_TOKEN`, then `~/.simplifyd/config.json`.

## Composability

Skills build on each other. The `status` skill provides preflight checks that operation skills reference before making changes.

## Shared Files

Scripts shared across skills live in `plugins/simplifyd/skills/_shared/scripts/edge-common.sh`.

## Adding New Skills

1. Create `plugins/simplifyd/skills/{name}/SKILL.md` with YAML frontmatter (`name`, `description`)
2. Use the `edge` CLI for all operations — prefer `--json` for machine-readable output
3. Reference `status` skill for preflight checks when needed
