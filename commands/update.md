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

## Step 2 — Update the Lore framework

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

- If `FRAMEWORK_UPDATED` and copy succeeded: note "✅ Framework updated."
- If copy failed: warn "⚠ Framework pulled but commands could not be updated. Run the setup script manually."

### Self-reload after update

After a successful pull **and** copy, immediately re-read the newly installed command file:

```
Read ~/.claude/commands/lore/update.md
```

Then continue execution from **Step 3** of that freshly-read file (do **not** re-run Steps 1 and 2).
Pass the original `$ARGUMENTS` through unchanged.

This ensures that any logic changes introduced in this very update take effect within the same session run.

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

Read `config.json` to get `REPO_URL` for this alias. Then run:

```bash
rm -rf ~/.claude/commands/<ALIAS>
mkdir -p ~/.claude/commands/<ALIAS>
BASE=~/.lore/.plugin/templates/_base.md.tpl
for f in ~/.lore/.plugin/templates/*.md.tpl; do
  name=$(basename "$f" .md.tpl)
  # Skip partials (files starting with _)
  [[ "$name" == _* ]] && continue
  # If template has no Step 1, prepend the shared base
  if ! grep -q "^## Step 1" "$f"; then
    cat "$BASE" "$f" | sed -e "s|{ALIAS}|<ALIAS>|g" \
        -e "s|{REPO_URL}|<REPO_URL>|g" \
        -e "s|{REPO_PATH}|~/.lore/<ALIAS>|g" \
        > ~/.claude/commands/<ALIAS>/${name}.md
  else
    sed -e "s|{ALIAS}|<ALIAS>|g" \
        -e "s|{REPO_URL}|<REPO_URL>|g" \
        -e "s|{REPO_PATH}|~/.lore/<ALIAS>|g" \
        "$f" > ~/.claude/commands/<ALIAS>/${name}.md
  fi
done
# Also generate plugin.json
sed -e "s|{ALIAS}|<ALIAS>|g" \
    -e "s|{REPO_URL}|<REPO_URL>|g" \
    -e "s|{REPO_PATH}|~/.lore/<ALIAS>|g" \
    ~/.lore/.plugin/templates/plugin.json.tpl > ~/.claude/commands/<ALIAS>/plugin.json
echo "Plugin regenerated: <ALIAS>"
```

If the loop fails: show the error and continue with the next alias.

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
