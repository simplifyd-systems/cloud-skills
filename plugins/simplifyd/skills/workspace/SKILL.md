---
name: workspace
description: Use this skill when the user wants to list, create, or switch workspaces on Simplifyd Cloud. Triggers on "list workspaces", "create workspace", "switch workspace", "use workspace", "workspace members", "workspace usage", or "what workspaces do I have".
allowed-tools: Bash(edge:*)
---

# Workspace Management

List, create, and switch between Simplifyd Cloud workspaces.

## When to Use

- User asks "what workspaces do I have?" or "list my workspaces"
- User wants to create a new workspace
- User wants to switch to a different workspace
- User asks about workspace members or resource usage
- Context errors mention "no workspace set"

## When NOT to Use

- User wants projects within a workspace → use `project` skill
- User wants environments → use `environment` skill

## List Workspaces

```bash
edge workspace list --json
```

Returns an array of workspace objects with: `id`, `slug`, `name`, `plan`, `created_at`.

Present as a table:

```
NAME        SLUG        PLAN     CREATED
my-team     my-team     pro      2024-01-15
personal    personal    free     2023-11-01
```

## Create Workspace

```bash
edge workspace create "My Team"
```

After creation, switch to it:

```bash
edge workspace use <slug>
```

## Switch Workspace

```bash
edge workspace use <slug>
```

Sets the active workspace in `~/.simplifyd/config.json`. All subsequent commands will use this workspace by default.

**To switch per-command without changing the default:**

```bash
edge project list --workspace other-team
```

## View Resource Usage

```bash
edge workspace usage --json
```

Returns: `services` count, `deployments` count, `members` count.

## Manage Members

```bash
edge workspace members list --json
```

Lists all members with: `id`, `email`, `first_name`, `last_name`, `role`.

**Add a member:**

```bash
edge workspace members add user@example.com
```

**Remove a member:**

```bash
edge workspace members remove <member-id>
```

## Decision Flow

```
User mentions workspace
        │
  List workspaces first?
        │
   ┌────┴────┐
 List      Create
   │           │
 Show       edge workspace create
 table      edge workspace use <slug>
```

## Context Hierarchy

Workspace context is resolved in this order:
1. `--workspace <slug>` flag on any command
2. `link_workspace` from `.edge.json` in current directory tree
3. `active_workspace` from `~/.simplifyd/config.json`

## Error Handling

### Not Authenticated

```
Error: not authenticated
```

→ Use `auth` skill to log in first.

### Workspace Not Found

```
Error: workspace not found
```

→ Run `edge workspace list` to see available workspaces and their slugs.

### Workspace Already Exists

```
Error: workspace name already taken
```

→ Choose a different name or use the existing workspace.

## Composability

- **After switching workspace**: Use `project` skill to set the project context
- **View services**: Use `service` skill (requires workspace + project + env context)
- **Check full context**: Use `status` skill
