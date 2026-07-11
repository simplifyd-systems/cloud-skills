---
name: auth
description: Use this skill when the user wants to log in, log out, or check who they are logged in as on Simplifyd Cloud. Triggers on "login", "logout", "who am I", "am I logged in", "edge auth login", "edge auth whoami", "authenticate", or "sign in".
allowed-tools: Bash(edge:*)
---

# Authentication

Manage authentication with Simplifyd Cloud.

## When to Use

- User wants to log in or authenticate: "login", "sign in", "authenticate"
- User wants to log out: "logout", "sign out"
- User wants to know who they're logged in as: "who am I", "whoami", "what account"
- Auth errors appear during other operations

## Check Current User

```bash
edge auth whoami --json
```

Returns user details: `id`, `email`, `first_name`, `last_name`.

## Login

```bash
edge auth login
```

Interactive login — prompts for email and password.

**Non-interactive (if email is known):**

```bash
edge auth login --email user@example.com
```

Still prompts for password interactively; password cannot be passed via flag for security.

**After login:** Token is stored in `~/.simplifyd/config.json`. All subsequent CLI commands use it automatically.

## Logout

```bash
edge auth logout
```

Clears the stored token and resets the active workspace/project/environment from `~/.simplifyd/config.json`.

## Token-Based Auth

For CI/CD or scripted access, set the token via environment variable instead of interactive login:

```bash
export CLOUD_TOKEN=<your-api-token>
edge service list  # uses CLOUD_TOKEN automatically
```

Or pass it per-command:

```bash
edge service list --token <your-api-token>
```

Token resolution order is `--token`, then `CLOUD_TOKEN`, then the stored token in `~/.simplifyd/config.json`.

Tokens are created and managed with the `token` skill.

## Error Handling

### Wrong Credentials

```
Error: invalid email or password
```

Ask the user to verify their email and password, or reset their password at https://console.cloud.simplifyd.com.

### Already Logged In

If the user is already authenticated, `edge auth whoami` succeeds. Inform them and show their current user info rather than prompting to log in again.

### Not Logged In

If `edge auth whoami` fails with "not authenticated":

> Not logged in. Run `edge auth login` to authenticate.

## Composability

- **After login**: Use `status` skill to verify context
- **Create API tokens for CI/CD**: Use `token` skill
- **Set active workspace after login**: Use `workspace` skill
