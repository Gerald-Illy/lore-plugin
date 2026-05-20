# /lore:status — Lore project status
# Powered by Lore — agentic intelligence graph and delivery engine

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

## Step 1.5 — Check for plugin updates

Run:
```bash
git -C ~/.lore/.plugin fetch --quiet 2>/dev/null
LOCAL=$(git -C ~/.lore/.plugin rev-parse HEAD 2>/dev/null)
REMOTE=$(git -C ~/.lore/.plugin rev-parse @{u} 2>/dev/null)
[ "$LOCAL" != "$REMOTE" ] && echo "PLUGIN_UPDATE_AVAILABLE" || echo "PLUGIN_CURRENT"
```

If `PLUGIN_UPDATE_AVAILABLE`:
- Show this notification once (before any other output):
  ```
  ℹ Lore plugin update available. Run: /lore:update --all
  ```
- **Continue with Step 2.** Do not block execution.

---

## Step 2 — Load config

Read `~/.lore/config.json`.

If the file does not exist or is empty:
- Tell the user: "No projects connected yet. Connect one with:"
  ```
  /lore:setup github:Owner/Repo <alias>
  ```
- **Stop here.**

---

## Step 3 — Show connected projects

For each project in `config.json → projects`:

Run per project:
```bash
git -C ~/.lore/<ALIAS> log --oneline -1 2>/dev/null || echo "SYNC_ERROR"
git -C ~/.lore/<ALIAS> log -1 --format="%ar" 2>/dev/null || echo "unknown"
```

Display a status table:

```
LORE — Connected Projects
════════════════════════════════════════════════════════

  Alias      Repo                                  Last sync
  ─────      ────                                  ─────────
  myproject  github.com/YourOrg/YourProject        2 hours ago
  work       github.com/YourOrg/AnotherProject     3 days ago

════════════════════════════════════════════════════════

Commands available:
  /<alias>:briefing [exec|vp|leads]
  /<alias>:ask [question]
  /<alias>:escalate [ID or description]
  /<alias>:overwrite "[wrong]" "[correct]"
  /<alias>:todo [text]
  /<alias>:note [text]
  /<alias>:recap [focus]
  /<alias>:feedback [text]
  /<alias>:help

Connect a new project:  /lore:setup <repo-url> <alias>
Sync projects:          /lore:sync [alias|--all]
Update framework:       /lore:update [alias|--all]
Uninstall project:      /lore:uninstall <alias>
Uninstall everything:   /lore:uninstall --all
Lore help:              /lore:help
Lore framework:         ~/.lore/.plugin (version: <read from ~/.lore/.plugin/.claude-plugin/plugin.json>)
```

If a project shows `SYNC_ERROR`: note it in the table as `⚠ repo missing — run /lore:setup again`.

---

## Step 4 — Suggest next step

If there is exactly one project: suggest `/<alias>:briefing leads`.
If there are multiple projects: suggest the one that was synced most recently.
If any project has a sync error: suggest fixing it first with `/lore:setup`.
