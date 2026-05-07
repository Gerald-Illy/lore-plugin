# /lore:status — Lore project status
# Powered by Lore — agentic intelligence graph and delivery engine

---

## Step 1 — Verify framework

Run:
```bash
test -d ~/.lore/.git && echo "OK" || echo "MISSING"
```

If `MISSING`:
- Tell the user: "Lore is not installed. Run the setup script to get started:"
  ```
  Mac/Linux:  bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.sh)
  Windows:    irm https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.ps1 | iex
  ```
- **Stop here.**

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
══════════════════════════════════════════════════════════

  Alias      Repo                                  Last sync
  ─────      ────                                  ─────────
  myproject  github.com/YourOrg/YourProject        2 hours ago
  work       github.com/YourOrg/AnotherProject     3 days ago

══════════════════════════════════════════════════════════

Commands available:
  /<alias>:briefing [exec|vp|leads]
  /<alias>:ask [question]
  /<alias>:escalate [ID or description]
  /<alias>:overwrite "[wrong]" "[correct]"
  /<alias>:help

Connect a new project:  /lore:setup <repo-url> <alias>
Update framework:       /lore:update [alias|--all]
Lore help:              /lore
Lore framework:         ~/.lore (version: <read from ~/.lore/.claude-plugin/plugin.json>)
```

If a project shows `SYNC_ERROR`: note it in the table as `⚠ repo missing — run /lore:setup again`.

---

## Step 4 — Suggest next step

If there is exactly one project: suggest `/<alias>:briefing leads`.
If there are multiple projects: suggest the one that was synced most recently.
If any project has a sync error: suggest fixing it first with `/lore:setup`.
