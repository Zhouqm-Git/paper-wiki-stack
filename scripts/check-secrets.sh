#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"

if [ ! -d "$ROOT" ]; then
  echo "Not a directory: $ROOT" >&2
  exit 2
fi

patterns=(
  "MINERU_API_TOKEN[[:space:]]*=[[:space:]]*['\\\"]?[^[:space:]'\\\"]{16,}"
  "ZOTERO_API_KEY[[:space:]]*=[[:space:]]*['\\\"]?[^[:space:]'\\\"]{16,}"
  "WEBDAV_PASS[[:space:]]*=[[:space:]]*['\\\"]?[^[:space:]'\\\"]{8,}"
  "api[_-]?key[[:space:]]*[:=][[:space:]]*['\\\"]?[^[:space:]'\\\"]{16,}"
  "token[[:space:]]*[:=][[:space:]]*['\\\"]?[^[:space:]'\\\"]{16,}"
  "password[[:space:]]*[:=][[:space:]]*['\\\"]?[^[:space:]'\\\"]{8,}"
)

exclude_args=(
  --glob '!.git/**'
  --glob '!node_modules/**'
  --glob '!dist/**'
  --glob '!build/**'
  --glob '!__pycache__/**'
)

found=0
for pattern in "${patterns[@]}"; do
  while IFS= read -r match; do
    case "$match" in
      *replace_with_*|*example.com*|*"/absolute/path/"*|*"/path/to/"*)
        continue
        ;;
    esac
    echo "$match"
    found=1
  done < <(rg -n -i "${exclude_args[@]}" "$pattern" "$ROOT" || true)
done

if [ "$found" -eq 0 ]; then
  echo "No obvious secrets found."
else
  echo "Potential secrets found. Review matches before publishing." >&2
  exit 1
fi
