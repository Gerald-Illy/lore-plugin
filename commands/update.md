# /lore:update — Update Lore framework and/or project plugins
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`
Format: (none) | `<alias>` | `--all`

- No arguments → update framework only
- `<alias>` → update framework + regenerate one project plugin
- `--all` → update framework + regenerate all connected project plugins

---

## Step 1 — Verify framework

Run:
```bash
test -d ~/.lore/.plugin/.git && echo "OK" || echo "MISSING"
```

If `MISSING`:
- Tell the user: "Lore framework not found at ~/.lore/.plugin/. Run `/lore:setup` to connect a project — it will bootstrap the framework automatically."
- **Stop here.**

---

## Step 2 — Self-update: pull framework and re-install framework commands

This step ensures that the regeneration logic (scripts, templates) is always the latest version — even if THIS command file is outdated.

Run:
```bash
git -C ~/.lore/.plugin pull --quiet && echo "FRAMEWORK_UPDATED" || echo "FRAMEWORK_ERROR"
```

- If `FRAMEWORK_ERROR`: warn "⚠ Could not pull framework from GitHub. Check your connection." Continue anyway (the rest can still run with what's on disk).

After a successful pull, re-install the framework commands (clean + copy to remove deleted commands):
```bash
rm -rf ~/.claude/commands/lore
mkdir -p ~/.claude/commands/lore
cp ~/.lore/.plugin/commands/* ~/.claude/commands/lore/
```

- If `FRAMEWORK_UPDATED` and copy succeeded: note "✅ Framework updated (commands re-installed)."
- If copy failed: warn "⚠ Framework pulled but commands could not be updated. Run the setup script manually."

---

## Step 3 — Determine scope from arguments

Parse `$ARGUMENTS`:

- Empty → set TARGETS = `[]` (framework only, no project regeneration)
- `--all` → set TARGETS = all aliases from `~/.lore/config.json → projects`
- Anything else → treat as a single alias, set TARGETS = `[<alias>]`

If `--all` and `config.json` does not exist or has no projects:
- Tell the user: "No connected projects found. Nothing to update beyond the framework."
- **Stop after Step 2 output.**

If a specific alias was given but it's not in `config.json`:
- Tell the user: "Project '<alias>' is not connected. Connect it first with `/lore:setup`."
- **Stop after Step 2 output.**

---

## Step 4 — For each target alias: pull the project repo

For each alias in TARGETS, run:
```bash
git -C ~/.lore/<ALIAS> pull --quiet && echo "PULLED" || echo "PULL_ERROR"
```

- If `PULL_ERROR`: warn "⚠ Could not pull <alias> — repo may be missing or offline."
  Set this alias to SKIP in the next step but continue with others.

---

## Step 5 — For each target alias: regenerate the project plugin

For each alias in TARGETS (that is not SKIP):

Read `config.json` to get `REPO_URL` for this alias. Then run the regeneration script from the freshly pulled framework:

```bash
bash ~/.lore/.plugin/scripts/regenerate.sh <ALIAS> <REPO_URL>
```

This script (pulled fresh in Step 2) handles:
- Cleaning old commands (`rm -rf ~/.claude/commands/<ALIAS>`)
- Generating all commands from current templates
- Generating `plugin.json` for version tracking

If the script outputs `REGENERATED:<ALIAS>` → success.
If it fails: show the error and continue with the next alias.

---

## Step 5.5 — Re-apply global permissions if settings.global.json changed

After framework pull (Step 2), check if the global permissions template changed:

```bash
SETTINGS_LOCAL="$HOME/.claude/settings.local.json"
NEEDS_UPDATE="no"

# Check if settings.local.json exists and has _lore block
if [ ! -f "$SETTINGS_LOCAL" ]; then
  NEEDS_UPDATE="missing"
elif ! jq -e '._lore' "$SETTINGS_LOCAL" >/dev/null 2>&1; then
  NEEDS_UPDATE="missing"
fi

echo "NEEDS_UPDATE:$NEEDS_UPDATE"
```

- If `NEEDS_UPDATE:missing` → the global permissions are not yet installed. Show the same notice as lore:setup Step 6.5 and offer to merge.
- If `NEEDS_UPDATE:no` → check if the template has new entries not yet in settings.local.json:

```bash
CURRENT_ALLOW=$(jq -r '.permissions.allow[]' "$SETTINGS_LOCAL" 2>/dev/null | sort)
TEMPLATE_ALLOW=$(jq -r '.permissions.allow[]' ~/.lore/.plugin/templates/settings.global.json 2>/dev/null | sort)
NEW_ENTRIES=$(comm -23 <(echo "$TEMPLATE_ALLOW") <(echo "$CURRENT_ALLOW"))
[ -n "$NEW_ENTRIES" ] && echo "NEW_ENTRIES:$NEW_ENTRIES" || echo "PERMISSIONS_CURRENT"
```

- If `NEW_ENTRIES:...` → inform the user: "New lore permissions are available:" + list them, then ask: "Add to ~/.claude/settings.local.json? (yes/no)"
  - yes → run `bash ~/.lore/.plugin/scripts/merge-global-settings.sh`
    - `MERGED` → show `✅ Permissions updated.`
    - `MERGE_FAILED:jq_missing` or `MERGE_FAILED:no_merge_tool` → tell user: "Install jq first (`winget install jqlang.jq` on Windows, `brew install jq` on Mac), then re-run `/lore:update`."
  - no → note "Skipped. Some alias commands may prompt for permissions."
- If `PERMISSIONS_CURRENT` → proceed silently.

---

## Step 6 — Summary

Display a summary of what happened:

```
LORE UPDATE COMPLETE
══════════════════════════════════════════════════════════

  Framework:   ✅ Updated (or ⚠ error message)

  Projects regenerated:
  ─────────────────────
  myproject    ✅ Plugin regenerated
  work         ⚠ Pull failed — skipped

══════════════════════════════════════════════════════════
```

If no projects were in scope (framework-only update):
```
  Projects:    (none — run /lore:update --all to also update project plugins)
```

Suggest next step:
- If any project was updated: suggest `/<first-updated-alias>:briefing leads`
- If any project failed: suggest `/lore:setup <repo-url> <alias>` for the failed one
- If framework-only: suggest `/lore:update --all` to also update project plugins
