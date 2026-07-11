# Simplifyd Cloud Skills

Agent Skills for working with Simplifyd Cloud through the `edge` CLI.

These skills package common Simplifyd Cloud workflows so supported developer tools can use the right CLI commands for authentication, context management, services, deployments, variables, tokens, registry pushes, and reference documentation.

## Install

Install from this repository with the `skills` CLI:

```bash
npx skills add simplifyd-systems/cloud-skills
```

Re-running the command updates an existing installation.

## Prerequisites

- The Simplifyd Cloud CLI, `edge`
- A Simplifyd Cloud account
- Docker, only if you use the `registry` skill to push local images

Authenticate before using operational skills:

```bash
edge auth login
```

For automation, set a project token instead:

```bash
export CLOUD_TOKEN=<token>
```

## Included Skills

| Skill | Purpose |
|-------|---------|
| `status` | Check authentication and active workspace, project, and environment context. |
| `auth` | Log in, log out, and show the current account. |
| `token` | Create, list, and delete API tokens. |
| `workspace` | List, create, switch workspaces, view usage, and manage members. |
| `project` | List, create, and switch projects. |
| `environment` | List, create, and switch environments. |
| `service` | Create, inspect, update, configure, connect to, and delete services. |
| `deploy` | Deploy, redeploy, stop services, and view deployment history. |
| `logs` | Stream deployment logs. |
| `variables` | List, set, and delete environment and service variables. |
| `registry` | Push local Docker images to the workspace registry. |
| `simplifyd-docs` | Provide reference information about Simplifyd Cloud features. |

## Repository Layout

```text
plugins/
  simplifyd/
    skills/
      auth/SKILL.md
      deploy/SKILL.md
      environment/SKILL.md
      logs/SKILL.md
      project/SKILL.md
      registry/SKILL.md
      service/SKILL.md
      simplifyd-docs/SKILL.md
      status/SKILL.md
      token/SKILL.md
      variables/SKILL.md
      _shared/scripts/edge-common.sh
```

## Security Notes

These skills call the `edge` CLI and can make real changes to Simplifyd Cloud resources. Review destructive operations before approving them, especially service deletion, undeploys, token deletion, and workspace member changes.

Use scoped project tokens for automation and store tokens in your tool or CI secret manager. Do not commit `~/.simplifyd/config.json`, API tokens, registry credentials, or `.env` files.

## Releases

Publish releases with Git tags:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The public repository should be:

```text
https://github.com/simplifyd-systems/cloud-skills
```
