---
name: project
description: Use this skill when the user wants to list, create, or switch projects on Simplifyd Cloud. Triggers on "list projects", "create project", "new project", "switch project", "use project", or "what projects do I have".
allowed-tools: Bash(edge:*)
---

# Project Management

List, create, and switch between projects within a Simplifyd Cloud workspace.

## When to Use

- User asks "what projects do I have?" or "list my projects"
- User wants to create a new project
- User wants to switch to a different project
- Context errors mention "no project set"

## When NOT to Use

- User wants to manage workspaces → use `workspace` skill
- User wants environments within a project → use `environment` skill
- User wants services → use `service` skill

## Prerequisites

A workspace must be set. Check with:

```bash
edge status --json
```

If `active_workspace` is empty, set it first:

```bash
edge workspace use <slug>
```

## List Projects

```bash
edge project list --json
```

Returns: `id`, `slug`, `name`, `workspace_id`, `created_at`.

Present as a table:

```
NAME       SLUG       CREATED
backend    backend    2024-02-01
frontend   frontend   2024-02-01
```

## Create Project

```bash
edge project create "My Project"
```

After creation, switch to it:

```bash
edge project use <slug>
```

## Switch Project

```bash
edge project use <slug>
```

Sets the active project in `~/.simplifyd/config.json`.

**To use a project per-command without changing the default:**

```bash
edge env list --project other-project
```

## Context Hierarchy

Project context is resolved in this order:
1. `--project <slug>` flag
2. `link_project` from `.edge.json`
3. `active_project` from `~/.simplifyd/config.json`

## Error Handling

### No Workspace Set

```
Error: workspace is required
```

→ Set active workspace: `edge workspace use <slug>`

### Project Not Found

```
Error: project not found
```

→ Run `edge project list` to see available projects and their slugs.

## Composability

- **After creating/switching project**: Use `environment` skill to set environment context
- **Manage services**: Use `service` skill (requires workspace + project + env)
- **Check full context**: Use `status` skill
