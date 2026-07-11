---
name: environment
description: Use this skill when the user wants to list, create, or switch environments on Simplifyd Cloud, or when they ask about "production", "staging", "development" environments, "what env am I in", "create an environment", or "switch to production".
allowed-tools: Bash(edge:*)
---

# Environment Management

List, create, and switch between environments within a Simplifyd Cloud project.

## When to Use

- User asks "what environments do I have?" or "list environments"
- User wants to create a new environment (staging, production, etc.)
- User wants to switch to a different environment
- Context errors mention "no environment set"
- User says "switch to production" or "use the staging environment"

## When NOT to Use

- User wants to manage environment variables → use `variables` skill
- User wants services within an environment → use `service` skill
- User wants to manage projects → use `project` skill

## Prerequisites

A workspace and project must be set:

```bash
edge status --json
```

If either is missing, set them first:

```bash
edge workspace use <workspace-slug>
edge project use <project-slug>
```

## List Environments

```bash
edge env list --json
```

Returns: `id`, `slug`, `name`, `project_id`, `created_at`.

Present as a table:

```
NAME         SLUG         CREATED
production   production   2024-02-01
staging      staging      2024-02-15
development  development  2024-02-20
```

## Create Environment

```bash
edge env create staging
```

Switch to it after creation:

```bash
edge env use staging
```

## Switch Environment

```bash
edge env use <slug>
```

Sets the active environment in `~/.simplifyd/config.json`.

**To use a specific environment per-command:**

```bash
edge service list --env staging
```

## Typical Environment Setup

For a new project, create standard environments:

```bash
edge env create production
edge env create staging
edge env create development
```

## Context Hierarchy

Environment context is resolved in this order:
1. `--env <slug>` flag
2. `link_env` from `.edge.json`
3. `active_env` from `~/.simplifyd/config.json`

## Linking a Directory

To persist workspace/project/environment context for a directory:

```bash
edge link --workspace my-team --project backend --env production
```

This creates `.edge.json` in the current directory. Any `edge` commands run in this directory (or subdirectories) will use these defaults automatically.

## Error Handling

### No Project Set

```
Error: project is required
```

→ Set active project: `edge project use <slug>`

### Environment Not Found

```
Error: environment not found
```

→ Run `edge env list` to see available environments and their slugs.

## Composability

- **After setting environment**: Use `service` skill to manage services
- **Manage env variables**: Use `variables` skill
- **Deploy a service**: Use `deploy` skill
- **Check full context**: Use `status` skill
