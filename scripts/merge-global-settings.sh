#!/bin/bash
# merge-global-settings.sh
# Merges lore permissions into ~/.claude/settings.local.json
# Called by lore:setup and lore:update
# Never modifies ~/.claude/settings.json

SETTINGS_LOCAL="$HOME/.claude/settings.local.json"
LORE_PERMS="$HOME/.lore/.plugin/templates/settings.global.json"

# ── jq path ──────────────────────────────────────────────────────────────────
if command -v jq >/dev/null 2>&1; then
  if [ -f "$SETTINGS_LOCAL" ]; then
    CURRENT=$(cat "$SETTINGS_LOCAL")
  else
    CURRENT="{}"
  fi

  LORE_ALLOW=$(jq '.permissions.allow' "$LORE_PERMS")
  LORE_META=$(jq '._lore' "$LORE_PERMS")

  RESULT=$(echo "$CURRENT" | jq \
    --argjson lore_allow "$LORE_ALLOW" \
    --argjson lore_meta "$LORE_META" \
    '._lore = $lore_meta | .permissions.allow = ((.permissions.allow // []) + $lore_allow | unique)')

  echo "$RESULT" > "$SETTINGS_LOCAL"
  echo "MERGED"
  exit 0
fi

# ── Python3 fallback (Mac / Linux without jq) ─────────────────────────────────
if command -v python3 >/dev/null 2>&1; then
  python3 - "$SETTINGS_LOCAL" "$LORE_PERMS" <<'PYEOF'
import json, sys, os

settings_path = sys.argv[1]
perms_path    = sys.argv[2]

current = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        current = json.load(f)

with open(perms_path) as f:
    template = json.load(f)

existing_allow = current.get("permissions", {}).get("allow", [])
lore_allow     = template["permissions"]["allow"]
merged_allow   = sorted(set(existing_allow + lore_allow))

if "permissions" not in current:
    current["permissions"] = {}
current["permissions"]["allow"] = merged_allow
current["_lore"] = template["_lore"]

with open(settings_path, "w") as f:
    json.dump(current, f, indent=2)

print("MERGED")
PYEOF
  exit 0
fi

# ── PowerShell fallback (Windows without jq) ─────────────────────────────────
PS=$(command -v pwsh 2>/dev/null || command -v powershell.exe 2>/dev/null)
if [ -n "$PS" ]; then
  "$PS" -NonInteractive -NoProfile -Command "
    \$settingsLocal = '$SETTINGS_LOCAL'
    \$lorePerms     = '$LORE_PERMS'

    if (Test-Path \$settingsLocal) {
      \$current = Get-Content \$settingsLocal -Raw | ConvertFrom-Json
    } else {
      \$current = [PSCustomObject]@{}
    }

    \$template = Get-Content \$lorePerms -Raw | ConvertFrom-Json

    if (-not \$current.PSObject.Properties['permissions']) {
      \$current | Add-Member -NotePropertyName 'permissions' -NotePropertyValue ([PSCustomObject]@{ allow = @() })
    }
    if (-not \$current.permissions.PSObject.Properties['allow']) {
      \$current.permissions | Add-Member -NotePropertyName 'allow' -NotePropertyValue @()
    }

    \$merged = (\$current.permissions.allow + \$template.permissions.allow) | Sort-Object -Unique
    \$current.permissions.allow = \$merged

    if (\$current.PSObject.Properties['_lore']) {
      \$current._lore = \$template._lore
    } else {
      \$current | Add-Member -NotePropertyName '_lore' -NotePropertyValue \$template._lore
    }

    \$current | ConvertTo-Json -Depth 10 | Set-Content \$settingsLocal -Encoding utf8
    Write-Output 'MERGED'
  "
  exit 0
fi

echo "MERGE_FAILED:no_merge_tool"
exit 1
