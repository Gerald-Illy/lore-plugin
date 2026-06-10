#!/bin/bash
# merge-global-settings.sh
# Merges lore permissions into ~/.claude/settings.local.json
# Called by lore:setup and lore:update
# Never modifies ~/.claude/settings.json

SETTINGS_LOCAL="$HOME/.claude/settings.local.json"
LORE_PERMS="$HOME/.lore/.plugin/templates/settings.global.json"

# Verify jq is available
if ! command -v jq >/dev/null 2>&1; then
  echo "MERGE_FAILED:jq_missing"
  exit 1
fi

# Read current settings.local.json — start with empty object if missing
if [ -f "$SETTINGS_LOCAL" ]; then
  CURRENT=$(cat "$SETTINGS_LOCAL")
else
  CURRENT="{}"
fi

# Extract lore permission list from template
LORE_ALLOW=$(jq '.permissions.allow' "$LORE_PERMS")
LORE_META=$(jq '._lore' "$LORE_PERMS")

# Merge: combine existing allow array with lore entries, deduplicate
RESULT=$(echo "$CURRENT" | jq \
  --argjson lore_allow "$LORE_ALLOW" \
  --argjson lore_meta "$LORE_META" \
  '._lore = $lore_meta | .permissions.allow = ((.permissions.allow // []) + $lore_allow | unique)')

echo "$RESULT" > "$SETTINGS_LOCAL"
echo "MERGED"
