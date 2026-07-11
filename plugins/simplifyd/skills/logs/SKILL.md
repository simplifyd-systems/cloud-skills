---
name: logs
description: Use this skill when the user wants to view, stream, or tail deployment logs on Simplifyd Cloud. Triggers on "show logs", "view logs", "tail logs", "stream logs", "what's in the logs", "deployment logs", "check logs", or "why is it failing" (investigate via logs).
allowed-tools: Bash(edge:*)
---

# Deployment Logs

Stream real-time logs from a service deployment on Simplifyd Cloud.

## When to Use

- User wants to see logs: "show logs", "check logs", "tail logs"
- User wants to debug a deployment: "why is it failing?", "what's the error?"
- User wants to watch a deployment as it starts
- After running `edge deploy up` to confirm the service started correctly

## When NOT to Use

- User wants to see deployment history (not logs) → use `deploy` skill
- User wants to create or manage services → use `service` skill

## Prerequisites

Workspace, project, environment, and service slug must be set. The service must have at least one deployment.

Check context:
```bash
edge status --json
```

List services if slug is unknown:
```bash
edge service list --json
```

List deployments to find the deployment slug:
```bash
edge deploy list --json
```

## Stream Logs (Latest Deployment)

```bash
edge deploy logs <svc-slug>
```

Streams logs from the most recent deployment. Logs are streamed via SSE (Server-Sent Events). Press Ctrl+C to stop.

**Example:**

```bash
edge deploy logs api
```

## Stream Logs for a Specific Deployment

```bash
edge deploy logs <svc-slug> --deployment <dep-slug>
```

Useful for reviewing logs from a past deployment.

## Follow Mode

```bash
edge deploy logs <svc-slug> --follow
```

Keeps streaming new log lines as they arrive. Use for watching a service in real-time.

## Interpreting Logs

Look for:
- **Startup messages**: Confirm the process started successfully
- **Port binding**: Ensure the app is listening on the expected port
- **Error messages**: Stack traces, connection failures, missing env vars
- **Crash loops**: Repeated start/crash cycles indicate a configuration or runtime error

### Common Issues

| Log Pattern | Likely Cause | Fix |
|---|---|---|
| `Error: cannot find module` | Missing dependency | Check image or add deps to Dockerfile |
| `EADDRINUSE: address already in use` | Port conflict | Change the service port |
| `Connection refused` to DB | Wrong DB URL | Check `DATABASE_URL` variable |
| `permission denied` | File/socket permissions | Check Dockerfile USER |
| Process exits immediately | Missing start command or crash | Check image's CMD/ENTRYPOINT |

## Flags Reference

| Flag | Description |
|------|-------------|
| `<svc-slug>` | Service slug (positional, required) |
| `--deployment <slug>` | Specific deployment slug (defaults to latest) |
| `--follow` / `-f` | Keep following new log output |

## Error Handling

### No Deployments Found

```
Error: no deployments found for service <slug>
```

→ The service hasn't been deployed yet. Run `edge deploy up <slug>` first.

### Service Not Found

```
Error: service not found
```

→ Run `edge service list --json` to find the correct service slug.

### Connection Error

If log streaming fails immediately:
→ Verify auth: `edge auth whoami`
→ Check context: `edge status --json`
→ Try listing deployments: `edge deploy list --json`

## Composability

- **Deploy first, then watch logs**: Use `deploy` skill → then `logs` skill
- **Debug by checking variables**: Use `variables` skill if logs show missing config
- **Check deployment status**: Use `deploy` skill for deployment history
