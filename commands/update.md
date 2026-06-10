# /lore:update — Update Lore framework and/or project plugins
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`
Format: (none) | `<alias>` | `--all` | `<alias> from lore-template`

- No arguments → update framework only
- `<alias>` → update framework + regenerate one project plugin
- `--all` → update framework + regenerate all connected project plugins
- `<alias> from lore-template` → compare project with template, offer selective sync

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
- Contains `from lore-template` → extract ALIAS (first word), set MODE = `template-sync`. **Skip Steps 4–6 entirely. Jump to Step 7 (Template Sync).**
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

---
---

# Template Sync Mode

## Step 7 — Verify template and project exist

**Only reached when MODE = `template-sync` (i.e. `$ARGUMENTS` contains `from lore-template`).**

Run:
```bash
test -d ~/.lore/.template/.git && echo "TEMPLATE_OK" || echo "TEMPLATE_MISSING"
test -d ~/.lore/<ALIAS> && echo "PROJECT_OK" || echo "PROJECT_MISSING"
```

If `TEMPLATE_MISSING`:
- Tell the user: "Template repo not found at ~/.lore/.template/. Run this to set it up:"
  ```bash
  git clone https://github.com/Gerald-Illy/lore-template.git ~/.lore/.template
  ```
- **Stop here.**

If `PROJECT_MISSING`:
- Tell the user: "Project '<ALIAS>' not found at ~/.lore/<ALIAS>/. Connect it first with `/lore:setup`."
- **Stop here.**

---

## Step 8 — Pull template (get latest)

```bash
git -C ~/.lore/.template pull --quiet && echo "TEMPLATE_SYNCED" || echo "TEMPLATE_PULL_ERROR"
```

- If `TEMPLATE_PULL_ERROR`: warn "⚠ Could not pull template. Comparing with local version." Continue.

---

## Step 9 — Create sync branch in project

```bash
cd ~/.lore/<ALIAS>
git checkout -b lore-template-sync-$(date +%Y-%m-%d)
```

If branch already exists (e.g. re-running today): checkout the existing branch instead:
```bash
git checkout lore-template-sync-$(date +%Y-%m-%d) 2>/dev/null || git checkout -b lore-template-sync-$(date +%Y-%m-%d)
```

Note: All subsequent operations happen inside `~/.lore/<ALIAS>/`.

---

## Step 10 — Compare framework files

Compare the following directories/files between template and project:

| Scope | Template path | Project path |
|-------|--------------|--------------|
| Skills | `~/.lore/.template/.claude/skills/` | `~/.lore/<ALIAS>/.claude/skills/` |
| Rules | `~/.lore/.template/.claude/rules/` | `~/.lore/<ALIAS>/.claude/rules/` |
| Refs | `~/.lore/.template/.claude/refs/` | `~/.lore/<ALIAS>/.claude/refs/` |
| Agents | `~/.lore/.template/.claude/agents/` | `~/.lore/<ALIAS>/.claude/agents/` |
| SOURCES.md | `~/.lore/.template/SOURCES.md` | `~/.lore/<ALIAS>/SOURCES.md` |
| SETUP.md | `~/.lore/.template/SETUP.md` | `~/.lore/<ALIAS>/SETUP.md` |

For each file in scope:
1. **List all files** in both template and project (recursively)
2. **Categorize** each file:
   - **New:** exists in template, not in project
   - **Changed:** exists in both, content differs (use `diff -q`)
   - **Identical:** exists in both, content is the same
   - **Only in project:** exists in project, not in template (informational only)

For **Changed** files: count the added/removed lines with `diff --stat` or `diff -u | grep -c '^[+-]'` and summarize what changed (read the diff, describe in 1 short line).

---

## Step 11 — Display comparison

Show this table:

```
TEMPLATE SYNC: <ALIAS> ← lore-template
══════════════════════════════════════════════════════════

  New in template (can be added):
  ───────────────────────────────
  .claude/skills/newskill/SKILL.md       Short description of what it does
  .claude/refs/new-ref.md                Short description

  Changed in template (can be updated):
  ──────────────────────────────────────
  .claude/refs/pull-framework.md         +114 lines — Source Resolution, Web Handling
  .claude/skills/pull/SKILL.md           +28 lines — web source integration
  SOURCES.md                             +121 lines — registry examples, web source docs

  Only in project (no action needed):
  ────────────────────────────────────
  .claude/skills/custom-skill/SKILL.md   (project-specific, not in template)

  Identical: N files (no changes needed)

══════════════════════════════════════════════════════════
```

If there are NO new or changed files:
- Tell the user: "✅ Project '<ALIAS>' is already in sync with the template. Nothing to update."
- Switch back to main: `git checkout main`
- **Stop here.**

Otherwise, ask the user:

```
What would you like to do?
  1. Apply all new + changed files
  2. Select specific files to update (list them)
  3. Show detailed diff for a file (name which one)
  4. Abort (switch back to main, delete branch)
```

Wait for user response. Handle accordingly:
- **Option 1:** Copy ALL new + changed files from template → project
- **Option 2:** User lists files → copy only those
- **Option 3:** Show `diff -u <template-file> <project-file>`, then ask again
- **Option 4:** Run `git checkout main && git branch -D lore-template-sync-$(date +%Y-%m-%d)`, stop.

---

## Step 12 — Apply changes

For each file the user approved:
```bash
cp ~/.lore/.template/<relative-path> ~/.lore/<ALIAS>/<relative-path>
```

For new files where the parent directory doesn't exist yet:
```bash
mkdir -p ~/.lore/<ALIAS>/<parent-dir>
cp ~/.lore/.template/<relative-path> ~/.lore/<ALIAS>/<relative-path>
```

After all files are copied:
```bash
cd ~/.lore/<ALIAS>
git add -A
git status
```

Show what was staged. Then commit:
```bash
git commit -m "sync: apply lore-template updates (<short summary of what was added/changed>)"
```

---

## Step 13 — Summary and next steps

```
TEMPLATE SYNC COMPLETE
══════════════════════════════════════════════════════════

  Project:  <ALIAS>
  Branch:   lore-template-sync-YYYY-MM-DD
  Commit:   <short sha> — sync: apply lore-template updates (...)

  Files updated: N new, M changed

══════════════════════════════════════════════════════════
```

Suggest next steps (pick 1–3 that are relevant):

1. **Test the changes:** `/<ALIAS>:ask what sources are configured?` (or similar command to verify)
2. **Create a PR:** `cd ~/.lore/<ALIAS> && git push -u origin lore-template-sync-YYYY-MM-DD` then create PR
3. **Merge directly:** `cd ~/.lore/<ALIAS> && git checkout main && git merge lore-template-sync-YYYY-MM-DD`
4. **Rollback:** `cd ~/.lore/<ALIAS> && git checkout main && git branch -D lore-template-sync-YYYY-MM-DD`
