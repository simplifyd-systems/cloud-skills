---
name: registry
description: Use this skill when the user wants to push a Docker image to the Simplifyd Cloud workspace registry, publish an image for deployment, use sdcr.io, or prepare a private image for a Simplifyd service. Triggers on "registry push", "push image", "publish Docker image", "sdcr.io", "workspace registry", "private registry", or "use my local image".
allowed-tools: Bash(edge:*), Bash(docker:*)
---

# Container Registry

Push local Docker images to the Simplifyd Cloud workspace registry.

## When to Use

- User wants to push a local Docker image for deployment
- User asks about `sdcr.io/<registry>/<image>:<tag>`
- User wants to use a private workspace registry image in a service
- User has built an image locally and wants to deploy it on Simplifyd Cloud

## When NOT to Use

- User wants to create or update a service with an already-pushed image -> use `service` skill
- User wants to deploy an existing service -> use `deploy` skill
- User wants to authenticate to Simplifyd Cloud -> use `auth` skill

## Prerequisites

- Docker daemon is running locally
- User is authenticated with `edge`
- Workspace context is set
- The workspace has a registry configured
- The local image exists

Check context:

```bash
edge status --json
```

Optionally check the local image:

```bash
docker image inspect myapp:latest
```

## Push an Image

```bash
edge registry push myapp:latest --json
```

If no tag is supplied, the CLI uses `latest`:

```bash
edge registry push myapp
```

In interactive terminals, omitting the image prompts for image name and tag:

```bash
edge registry push
```

The JSON output contains:

```json
{"image":"sdcr.io/<registry-name>/<image>:<tag>"}
```

Use that full image reference when creating or updating Docker services.

## Create or Update a Service with the Pushed Image

Create:

```bash
edge service create --name api --type docker --image sdcr.io/my-registry/api:1.0
```

Update:

```bash
edge service update api --image sdcr.io/my-registry/api:1.0
edge deploy up api
```

## Error Handling

### Docker Not Running

If Docker commands fail or the push cannot create a Docker client, ask the user to start Docker and retry.

### Local Image Missing

```
Error: tagging image
```

Verify the image exists locally:

```bash
docker image inspect <image>:<tag>
```

### No Registry Configured

```
Error: no registry configured for this workspace
```

The workspace must have a container registry configured before image pushes can work.

### Missing Workspace

```
Error: no workspace set
```

Set it with `edge workspace use <slug>` or pass `--workspace <slug>`.

## Composability

- Build images with Docker before using this skill
- Use `service` skill to create or update services with the returned image
- Use `deploy` skill after updating a service image
