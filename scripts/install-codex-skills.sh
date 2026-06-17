#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /absolute/path/to/claude-obsidian" >&2
  exit 2
fi

VAULT_ROOT_INPUT="$1"
SKILLS_SRC="$VAULT_ROOT_INPUT/skills"
CODEX_SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "Missing skills directory: $SKILLS_SRC" >&2
  exit 1
fi

mkdir -p "$CODEX_SKILLS_DIR"

for skill_dir in "$SKILLS_SRC"/*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue
  name="$(basename "$skill_dir")"
  target="$CODEX_SKILLS_DIR/claude-obsidian-$name"
  rm -f "$target"
  ln -s "$skill_dir" "$target"
  echo "Linked $target -> $skill_dir"
done

echo "Restart Codex to reload skills."
