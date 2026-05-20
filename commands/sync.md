# /lore:sync — Sync Lore projects
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`
Format: `[alias|--all]` (optional — defaults to all projects)
Examples:
- `/lore:sync` — sync all connected projects
- `/lore:sync dta` — sync only the `dta` project
- `/lore:sync --all` — same as no argument

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

## Step 2 — Parse arguments

Parse `$ARGUMENTS`:

- No argument or `--all` → sync ALL projects from `~/.lore/config.json`
- A specific alias → sync only that project

Read `~/.lore/config.json`. If it does not exist or has no projects:
- Tell the user: "No projects connected. Connect one with: `/lore:setup github:Owner/Repo <alias>`"
- **Stop here.**

If a specific alias was given but is not in `config.json`:
- Tell the user: "Project `<alias>` is not connected. Check connected projects with `/lore:status`."
- **Stop here.**

---

## Step 3 — Sync each target project

For each project to sync, run these steps in order:

```bash
ALIAS="<alias>"
REPO_PATH=~/.lore/$ALIAS

# Fetch
git -C $REPO_PATH fetch --quiet 2>&1 || echo "FETCH_FAILED:$ALIAS"

# Merge (fast-forward only to avoid conflicts)
git -C $REPO_PATH merge --ff-only @{u} 2>&1 || echo "MERGE_FAILED:$ALIAS"

# Push (send local commits like contributions/ files)
git -C $REPO_PATH push --quiet 2>&1 || echo "PUSH_FAILED:$ALIAS"
```

Track results per project:
- **FETCH_FAILED** → "⚠ Could not reach remote for `<alias>`. Check your network or run `gh auth login`."
- **MERGE_FAILED** → "⚠ `<alias>` has diverged. Resolve manually: `git -C ~/.lore/<alias> pull --rebase`"
- **PUSH_FAILED** → "ℹ `<alias>` pulled but push failed (no write access or nothing to push). Local changes stay local."
- All succeeded → "✅ `<alias>` synced."

---

## Step 4 — Sync the framework

Run:
```bash
git -C ~/.lore/.plugin pull --quiet 2>/dev/null && echo "FRAMEWORK_OK" || echo "FRAMEWORK_FAILED"
```

- `FRAMEWORK_OK` → include in summary
- `FRAMEWORK_FAILED` → "⚠ Framework sync failed. Try: `/lore:update`"

---

## Step 5 — Reset session markers

For each successfully synced project, reset its session marker:
```bash
date +%s > /tmp/.lore-session-$ALIAS
```

This prevents the staleness hint from firing immediately after a sync.

---

## Step 6 — Show summary

Display:

```
Lore Sync — Complete
══════════════════════════════════════════

  <alias1>    ✅ synced (pulled 3 commits, pushed 2 commits)
  <alias2>    ✅ synced (up to date)
  framework   ✅ synced

══════════════════════════════════════════
```

Adapt the detail per project (commits pulled/pushed, up to date, or error message).

---

## Step 7 — Suggest next steps

- If changes were pulled → "See what's new? `/<alias>:briefing leads`"
- If push failed → "Check access: ask the repo owner for write permissions."
- If merge failed → "Resolve conflicts: `git -C ~/.lore/<alias> status`"
- All clean → "You're up to date. Try: `/<alias>:ask [question]`"

Max 3. Pick what's most relevant.
