#!/usr/bin/env bash
# regenerate.sh — Generate project plugin commands from templates
# Called by /lore:setup and /lore:update
# Usage: bash regenerate.sh <ALIAS> <REPO_URL>

set -euo pipefail

ALIAS="$1"
REPO_URL="$2"
REPO_PATH="~/.lore/$ALIAS"
TEMPLATE_DIR=~/.lore/.plugin/templates

if [ -z "$ALIAS" ] || [ -z "$REPO_URL" ]; then
  echo "ERROR: Usage: regenerate.sh <ALIAS> <REPO_URL>"
  exit 1
fi

# Clean existing commands for this alias
rm -rf ~/.claude/commands/$ALIAS
mkdir -p ~/.claude/commands/$ALIAS

# Generate _preamble.md (runtime shared context, read by every skill)
sed -e "s|{ALIAS}|$ALIAS|g" \
    -e "s|{REPO_URL}|$REPO_URL|g" \
    -e "s|{REPO_PATH}|$REPO_PATH|g" \
    "$TEMPLATE_DIR/_preamble.md.tpl" > ~/.claude/commands/$ALIAS/_preamble.md

# Generate skill commands from templates
for f in "$TEMPLATE_DIR"/*.md.tpl; do
  name=$(basename "$f" .md.tpl)
  # Skip partials (files starting with _)
  [[ "$name" == _* ]] && continue
  sed -e "s|{ALIAS}|$ALIAS|g" \
      -e "s|{REPO_URL}|$REPO_URL|g" \
      -e "s|{REPO_PATH}|$REPO_PATH|g" \
      "$f" > ~/.claude/commands/$ALIAS/${name}.md
done

# Generate plugin.json
sed -e "s|{ALIAS}|$ALIAS|g" \
    -e "s|{REPO_URL}|$REPO_URL|g" \
    -e "s|{REPO_PATH}|$REPO_PATH|g" \
    "$TEMPLATE_DIR/plugin.json.tpl" > ~/.claude/commands/$ALIAS/plugin.json

# Generate settings.json
sed -e "s|{ALIAS}|$ALIAS|g" \
    -e "s|{REPO_URL}|$REPO_URL|g" \
    -e "s|{REPO_PATH}|$REPO_PATH|g" \
    "$TEMPLATE_DIR/settings.json.tpl" > ~/.claude/commands/$ALIAS/settings.json

echo "REGENERATED:$ALIAS"
