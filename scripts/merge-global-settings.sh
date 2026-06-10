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

# ── PowerShell fallback (Windows / no jq) ────────────────────────────────────
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
