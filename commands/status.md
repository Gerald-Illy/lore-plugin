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

## Step 1.5 — Session checks (once per session)

Run:
```bash
MARKER="/tmp/.lore-session-lore"
if [ -f "$MARKER" ] && [ $(( $(date +%s) - $(cat "$MARKER") )) -lt 14400 ]; then
  echo "SESSION_OK"
else
  git -C ~/.lore/.plugin fetch --quiet 2>/dev/null
  LOCAL=$(git -C ~/.lore/.plugin rev-parse HEAD 2>/dev/null)
  REMOTE=$(git -C ~/.lore/.plugin rev-parse @{u} 2>/dev/null)
  [ "$LOCAL" != "$REMOTE" ] && echo "PLUGIN_UPDATE_AVAILABLE" || echo "PLUGIN_CURRENT"
  date +%s > "$MARKER"
fi
```

Handle the output:

- `PLUGIN_UPDATE_AVAILABLE` → Show once:
  ```
  ℹ Lore plugin update available. Run: /lore:update --all
  ```
- `SESSION_OK` or `PLUGIN_CURRENT` → proceed silently.

**Continue with Step 2 in all cases.**

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

## Step 3 — Show connected projects with version check

**Read the framework version (latest available):**
```bash
cat ~/.lore/.plugin/.claude-plugin/plugin.json 2>/dev/null
```
Extract the `version` field → this is the **repo version** (what's available).

**For each project in `config.json → projects`:**

Run per project — substitute the literal alias value directly (no shell variables):
```bash
git -C ~/.lore/<alias> log -1 --format="%ar" 2>/dev/null || echo "SYNC_ERROR"
cat ~/.claude/commands/<alias>/plugin.json 2>/dev/null || echo "NOT_INSTALLED"
```

Compare the `version` field from `~/.claude/commands/<alias>/plugin.json` (installed) against the framework repo version (available).

Display a status table:

```
LORE — Connected Projects
══════════════════════════════════════════════════════════════════════════════════════════════

  Alias      Repo                                  Last sync       Installed
  ─────      ────                                  ─────────       ─────────
  myproject  github.com/YourOrg/YourProject        2 hours ago     ✅ v1.3.0
  work       github.com/YourOrg/AnotherProject     3 days ago      ⚠ v1.1.0 (outdated)

  Framework repo:     v1.3.0 (latest)
  Framework commands: ~/.lore/.plugin

══════════════════════════════════════════════════════════════════════════════════════════════

Commands available:
  /<alias>:briefing [exec|vp|leads]
  /<alias>:ask [question]
  /<alias>:escalate [ID or description]
  /<alias>:overwrite "[wrong]" "[correct]"
  /<alias>:jot [text]
  /<alias>:reasoning [question]
  /<alias>:publish [mode] [artifact]
  /<alias>:pull [scope]
  /<alias>:setup [action]
  /<alias>:help

Connect a new project:  /lore:setup <repo-url> <alias>
Create from template:   /lore:setup new <alias>
Sync projects:          /lore:sync [alias|--all]
Update framework:       /lore:update [alias|--all]
Uninstall project:      /lore:uninstall <alias>
Uninstall everything:   /lore:uninstall --all
Lore help:              /lore:help
```

**Version status per project:**
- Installed version matches repo version → `✅ v1.3.0`
- Installed version is older → `⚠ v1.1.0 (outdated → run /lore:update <alias>)`
- No `plugin.json` found in commands dir → `❌ not installed (run /lore:setup)`

If a project shows `SYNC_ERROR`: note it as `⚠ repo missing — run /lore:setup again`.

---

## Step 4 — Suggest next step

- If any project is **outdated**: suggest `/lore:update --all` first.
- If any project has a **sync error**: suggest `/lore:setup` for that project.
- If everything is up to date and there is exactly one project: suggest `/<alias>:briefing leads`.
- If everything is up to date and there are multiple projects: suggest the one synced most recently.
