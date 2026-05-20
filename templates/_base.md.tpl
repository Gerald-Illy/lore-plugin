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
  git -C ~/.lore/.plugin fetch --quiet 2>/dev/null
  LOCAL=$(git -C ~/.lore/.plugin rev-parse HEAD 2>/dev/null)
  REMOTE=$(git -C ~/.lore/.plugin rev-parse @{u} 2>/dev/null)
  [ "$LOCAL" != "$REMOTE" ] && echo "PLUGIN_UPDATE_AVAILABLE" || echo "PLUGIN_CURRENT"
  date +%s > "$MARKER"
elif [ $(( $(date +%s) - $(cat "$MARKER") )) -gt 14400 ]; then
  echo "SESSION_STALE"
else
  echo "SESSION_OK"
fi
```

Handle the output:

- `PLUGIN_UPDATE_AVAILABLE` → Show once (before any other output):
  ```
  ℹ Lore plugin update available. Run: /lore:update --all
  ```
- `SESSION_STALE` → Show once:
  ```
  ℹ Session active for >4h. Consider syncing: /lore:sync {ALIAS}
  ```
- `SESSION_OK` or `PLUGIN_CURRENT` → proceed silently.

**Continue with Step 2 in all cases.** Never block execution.

## Step 2 — Load identity

Read `{REPO_PATH}/CLAUDE.md` and internalize it fully.
All rules and behavioral guidelines defined there apply for this session.

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
