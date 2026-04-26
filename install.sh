#!/bin/bash
# Install Claude Code skills by symlinking to ~/.claude/commands/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.claude/commands"

mkdir -p "$TARGET_DIR"

for skill in "$SCRIPT_DIR"/commands/*.md; do
  name="$(basename "$skill")"
  ln -sf "$skill" "$TARGET_DIR/$name"
  echo "  linked $name"
done

echo "Done. Skills available in Claude Code via /command-name."
