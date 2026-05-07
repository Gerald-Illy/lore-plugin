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
test -d ~/.lore/.git && echo "OK" || echo "MISSING"
```

If `MISSING`:
- Tell the user: "Lore is not installed. Run the setup script first:"
  ```
  Mac/Linux:  bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.sh)
  Windows:    irm https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.ps1 | iex
  ```
- **Stop here.**

---

## Step 2 — Update the Lore framework

Run:
```bash
git -C ~/.lore pull --quiet && echo "FRAMEWORK_UPDATED" || echo "FRAMEWORK_ERROR"
```

- If `FRAMEWORK_UPDATED`: note "✅ Framework updated."
- If `FRAMEWORK_ERROR`: warn "⚠ Could not pull framework from GitHub. Check your connection." Continue anyway (the rest can still run with what's on disk).

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

Read `config.json` to get `REPO_URL` and `REPO_PATH` for this alias.

Read each template from `~/.lore/templates/`, substitute tokens, write to target:

**Substitution tokens:**
- `{ALIAS}` → alias value
- `{REPO_URL}` → repo URL from config
- `{REPO_PATH}` → `~/.lore/<ALIAS>` (literal, not shell-expanded)

**File mapping:**

| Template source | Target path |
|----------------|-------------|
| `~/.lore/templates/plugin.json.tpl` | `~/.lore/<ALIAS>/.lore-plugin/.claude-plugin/plugin.json` |
| `~/.lore/templates/briefing.md.tpl` | `~/.lore/<ALIAS>/.lore-plugin/commands/briefing.md` |
| `~/.lore/templates/ask.md.tpl` | `~/.lore/<ALIAS>/.lore-plugin/commands/ask.md` |
| `~/.lore/templates/escalate.md.tpl` | `~/.lore/<ALIAS>/.lore-plugin/commands/escalate.md` |
| `~/.lore/templates/overwrite.md.tpl` | `~/.lore/<ALIAS>/.lore-plugin/commands/overwrite.md` |
| `~/.lore/templates/help.md.tpl` | `~/.lore/<ALIAS>/.lore-plugin/commands/help.md` |

After writing, reinstall the plugin:
```bash
claude plugin install ~/.lore/<ALIAS>/.lore-plugin --scope user
```

If install fails: show the manual command and continue with the next alias.

---

## Step 6 — Summary

Display a summary of what happened:

```
LORE UPDATE COMPLETE
══════════════════════════════════════════════════════════

  Framework:   ✅ Updated (or ⚠ error message)

  Projects regenerated:
  ─────────────────────
  myproject    ✅ Plugin regenerated and reinstalled
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
