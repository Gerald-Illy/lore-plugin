# Powered by Lore — agentic intelligence graph and delivery engine

## Step 1 — Sync the repo

Run:
```bash
git -C {REPO_PATH} pull --quiet 2>/dev/null || echo "REPO_MISSING"
```

If the output contains `REPO_MISSING`:
- Tell the user: "The Lore repo for `{ALIAS}` is not found locally. Reconnect with: `/lore:setup {REPO_URL} {ALIAS}`"
- **Stop here. Do not continue.**

## Step 1.5 — Session checks (once per session)

Run:
```bash
MARKER="/tmp/.lore-session-{ALIAS}"
if [ ! -f "$MARKER" ]; then
  # First run this session — check installed vs available version
  INSTALLED=$(grep -o '"version": "[^"]*"' ~/.claude/commands/{ALIAS}/plugin.json 2>/dev/null | grep -o '[0-9][0-9.]*')
  AVAILABLE=$(grep -o '"version": "[^"]*"' ~/.lore/.plugin/.claude-plugin/plugin.json 2>/dev/null | grep -o '[0-9][0-9.]*')
  if [ -n "$AVAILABLE" ] && [ "$INSTALLED" != "$AVAILABLE" ]; then
    echo "COMMANDS_OUTDATED:$INSTALLED:$AVAILABLE"
  else
    echo "COMMANDS_CURRENT"
  fi
  date +%s > "$MARKER"
elif [ $(( $(date +%s) - $(cat "$MARKER") )) -gt 14400 ]; then
  echo "SESSION_STALE"
else
  echo "SESSION_OK"
fi
```

Handle the output:

- `COMMANDS_OUTDATED:<old>:<new>` → Show once (before any other output):
  ```
  ⚠ Plugin commands outdated (v<old> → v<new>). Run: /lore:update {ALIAS}
  ```
- `SESSION_STALE` → Show once:
  ```
  ℹ Session active for >4h. Consider syncing: /lore:sync {ALIAS}
  ```
- `SESSION_OK` or `COMMANDS_CURRENT` → proceed silently.

**Continue with Step 2 in all cases.** Never block execution.

## Step 2 — Load identity

Read `{REPO_PATH}/CLAUDE.md` and internalize it fully.
All rules and behavioral guidelines defined there apply for this session.

**Skip any update/version check** defined in the project's CLAUDE.md — Step 1.5 already handles this.

## Step 2.5 — Enter Lore context

**Switch working directory:**
```bash
cd {REPO_PATH}
```
From this point on, ALL relative paths resolve against `{REPO_PATH}`.

**Load governance rules** — read each file and internalize:
- `{REPO_PATH}/.claude/rules/never-invent.md`
- `{REPO_PATH}/.claude/rules/privacy.md`
- `{REPO_PATH}/.claude/refs/tagging.md`
- `{REPO_PATH}/.claude/refs/ai-inference.md`

**Load corrections:**
- `{REPO_PATH}/OVERRIDES.md`

If any file does not exist, skip it silently and continue.
