#!/usr/bin/env bash
# Shared Simplifyd Cloud CLI utilities for Simplifyd Cloud skills

check_edge_cli() {
  if command -v edge &>/dev/null; then
    echo '{"installed": true, "path": "'$(which edge)'"}'
    return 0
  else
    echo '{"installed": false, "error": "cli_missing"}'
    return 1
  fi
}

check_edge_auth() {
  local whoami_output
  whoami_output=$(edge auth whoami --json 2>&1)
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "$whoami_output"
    return 0
  else
    echo '{"authenticated": false, "error": "not_authenticated"}'
    return 1
  fi
}

check_edge_context() {
  local status_output
  status_output=$(edge status --json 2>&1)
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "$status_output"
    return 0
  else
    echo '{"linked": false, "error": "no_context"}'
    return 1
  fi
}

# Run all preflight checks: CLI installed, authenticated, context set.
# Prints status JSON on success, error JSON on failure.
edge_preflight() {
  # Check CLI installed
  if ! command -v edge &>/dev/null; then
    echo '{"ready": false, "error": "cli_missing"}'
    return 1
  fi

  # Check authenticated
  local auth_check
  auth_check=$(edge auth whoami --json 2>&1)
  if [[ $? -ne 0 ]]; then
    echo '{"ready": false, "error": "not_authenticated"}'
    return 1
  fi

  # Return full status
  local status_output
  status_output=$(edge status --json 2>&1)
  if [[ $? -ne 0 ]]; then
    echo '{"ready": false, "error": "status_failed"}'
    return 1
  fi

  echo "$status_output"
  return 0
}
