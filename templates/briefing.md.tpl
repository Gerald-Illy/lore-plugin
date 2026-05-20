# /{ALIAS}:briefing — Stakeholder Briefing

Arguments: `$ARGUMENTS` (expected: `exec`, `vp`, or `leads`)

## Step 0 — Help check

If `$ARGUMENTS` is exactly `--help` or `-h`:
1. Sync the repo first (run the git pull from Step 1 so paths are available)
2. Find the skill path referenced in Step 3 of this file (e.g. `{REPO_PATH}/.claude/skills/briefing/SKILL.md`)
3. If that SKILL.md exists and contains a `## Help` section → display the skill's Help section
4. Otherwise → find the `## Help` section below in this command file and display it
- **Stop here. Do not continue with Step 2.**

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

## Available plugin commands

Only the following commands are installed as global plugin commands:

- `/{ALIAS}:briefing` `/{ALIAS}:ask` `/{ALIAS}:escalate` `/{ALIAS}:overwrite`
- `/{ALIAS}:todo` `/{ALIAS}:note` `/{ALIAS}:recap` `/{ALIAS}:feedback`
- `/{ALIAS}:help`

**Rule:** When suggesting follow-up commands (Step 5), ONLY suggest commands from this list.
If the skill's SKILL.md or the project's CLAUDE.md references other commands (e.g. `/pull`, `/inconsistencies`, `/plan`), these are **repo-only commands** — they are not available as plugin commands. Either:
- Skip them entirely, OR
- Frame them as: "For deeper operations, work inside the repo directly: `cd ~/.lore/{ALIAS}` then use `/<command>`"

Never suggest a command that doesn't exist as an installed plugin command.

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/briefing/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `briefing` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the briefing skill exactly as defined in SKILL.md.
Pass `$ARGUMENTS` as the audience parameter. If no argument was provided, default to `leads`.

**If a CLI tool is missing:** When the skill needs `acli-pii` (Jira/Confluence) or `gh` (GitHub) but the tool is not available:
1. Complete the briefing with what you CAN access (knowledge/, logs/, OVERRIDES.md)
2. Then note:
   ```
   ℹ Briefing from local Lore only. For live source data, install:
   [specific install command]
   Then retry: /{ALIAS}:briefing $ARGUMENTS
   ```

## Step 5 — Suggest next steps

After the briefing, suggest 2–3 contextual follow-up actions based on what surfaced.

- Risks surfaced → "Escalate one? `/{ALIAS}:escalate [risk]`"
- Decisions pending → "Dig deeper? `/{ALIAS}:ask "What's blocking [decision]?"`"
- Thin data on a workstream → "Check it? `/{ALIAS}:ask "Status of [workstream]?"`"
- All clear → "Prep next level up: `/{ALIAS}:briefing vp`"

Phrase as copy-pasteable commands. Max 3. Pick what's most actionable.

## Help

```
/{ALIAS}:briefing — Stakeholder Briefing

Usage:  /{ALIAS}:briefing [audience]

Arguments:
  exec     C-Level strategic summary
  vp       VP-level full project view
  leads    Delivery lead operational view (default)

Examples:
  /{ALIAS}:briefing leads
  /{ALIAS}:briefing vp
  /{ALIAS}:briefing exec
```
