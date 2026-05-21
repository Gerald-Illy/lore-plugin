# Lore Preamble — {ALIAS}
# Execute these steps BEFORE every skill command in this directory.

## Step 0 — Help check

If `$ARGUMENTS` is exactly `--help` or `-h`:
1. Check if `{REPO_PATH}` exists (no git pull needed — just local path check)
2. Find the skill path referenced in Step 3 of the calling command file
3. If that SKILL.md exists and contains a `## Help` or `## --help` section → display the skill's help
4. Otherwise → find the `## Help` section in the calling command file and display it
- **Stop here. Do not continue.**

## Step 1 — Session sync (once per session)

Run:
```bash
MARKER="/tmp/.lore-session-{ALIAS}"
if [ -f "$MARKER" ] && [ $(( $(date +%s) - $(cat "$MARKER") )) -lt 14400 ]; then
  echo "SESSION_OK"
else
  echo "FIRST_RUN"
fi
```

Handle the output:

- **`FIRST_RUN`** — First command this session (or >4h since last sync). Do all of the following:
  1. Pull the project repo:
     ```bash
     git -C {REPO_PATH} pull --quiet 2>/dev/null || echo "REPO_MISSING"
     ```
     If `REPO_MISSING`: tell the user "The Lore repo for `{ALIAS}` is not found locally. Reconnect with: `/lore:setup {REPO_URL} {ALIAS}`" — **Stop here.**
  2. Check for plugin updates:
     ```bash
     INSTALLED=$(grep -o '"version": "[^"]*"' ~/.claude/commands/{ALIAS}/plugin.json 2>/dev/null | grep -o '[0-9][0-9.]*')
     AVAILABLE=$(grep -o '"version": "[^"]*"' ~/.lore/.plugin/.claude-plugin/plugin.json 2>/dev/null | grep -o '[0-9][0-9.]*')
     [ -n "$AVAILABLE" ] && [ "$INSTALLED" != "$AVAILABLE" ] && echo "COMMANDS_OUTDATED:$INSTALLED:$AVAILABLE"
     ```
     If `COMMANDS_OUTDATED:<old>:<new>` → show once: `⚠ Plugin commands outdated (v<old> → v<new>). Run: /lore:update {ALIAS}`
  3. Write the session marker:
     ```bash
     date +%s > /tmp/.lore-session-{ALIAS}
     ```

- **`SESSION_OK`** — Proceed silently. No pull, no checks.

**Continue with Step 2 in all cases** (unless stopped by REPO_MISSING).

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

## Available plugin commands

Only the following commands are installed as global plugin commands:

- `/{ALIAS}:briefing` `/{ALIAS}:ask` `/{ALIAS}:escalate` `/{ALIAS}:overwrite`
- `/{ALIAS}:jot` `/{ALIAS}:help`

**Rule:** When suggesting follow-up commands, ONLY suggest commands from this list.
If the skill's SKILL.md or the project's CLAUDE.md references other commands (e.g. `/pull`, `/inconsistencies`, `/plan`), these are **repo-only commands** — they are not available as plugin commands. Either:
- Skip them entirely, OR
- Frame them as: "For deeper operations, work inside the repo directly: `cd ~/.lore/{ALIAS}` then use `/<command>`"

Never suggest a command that doesn't exist as an installed plugin command.
