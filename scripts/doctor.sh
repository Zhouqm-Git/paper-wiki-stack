#!/usr/bin/env bash
set -euo pipefail

failures=0

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "OK command: $1"
  else
    echo "MISSING command: $1"
    failures=$((failures + 1))
  fi
}

check_env() {
  if [ -n "${!1:-}" ]; then
    echo "OK env: $1"
  else
    echo "MISSING env: $1"
    failures=$((failures + 1))
  fi
}

check_cmd python3
check_cmd pip
check_cmd curl
check_cmd zotero-mcp
check_cmd mineru-zotero-mcp

check_env MINERU_API_TOKEN
check_env VAULT_ROOT
check_env ZOTERO_LIBRARY_ID
check_env ZOTERO_USER_ID
check_env ZOTERO_API_KEY

if [ -n "${VAULT_ROOT:-}" ]; then
  if [ -d "$VAULT_ROOT/skills/paper-wiki" ]; then
    echo "OK vault paper-wiki skill: $VAULT_ROOT/skills/paper-wiki"
  else
    echo "MISSING vault paper-wiki skill under VAULT_ROOT"
    failures=$((failures + 1))
  fi

  if [ -f "$VAULT_ROOT/skills/paper-wiki/scripts/build_indexes.py" ]; then
    echo "OK build_indexes.py"
  else
    echo "MISSING build_indexes.py"
    failures=$((failures + 1))
  fi
fi

if curl -fsS --max-time 2 http://127.0.0.1:23119/better-bibtex/json-rpc >/dev/null 2>&1; then
  echo "OK Better BibTeX local endpoint reachable"
else
  echo "WARN Better BibTeX endpoint not reachable at 127.0.0.1:23119"
fi

if [ "$failures" -eq 0 ]; then
  echo "Doctor passed."
else
  echo "Doctor failed with $failures missing requirement(s)." >&2
  exit 1
fi
