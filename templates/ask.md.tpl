# /{ALIAS}:ask — Query Lore

Arguments: `$ARGUMENTS` (your question — any natural language)

## Step 0 — Help check

If `$ARGUMENTS` is exactly `--help` or `-h`:
1. Sync the repo first (run the git pull from Step 1 so paths are available)
2. Find the skill path referenced in Step 3 of this file (e.g. `{REPO_PATH}/.claude/skills/ask/SKILL.md`)
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

Check if `{REPO_PATH}/.claude/skills/ask/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `ask` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the ask skill exactly as defined in SKILL.md.
The question to answer is: `$ARGUMENTS`

If no argument was provided: ask the user what they want to know.

**If a CLI tool is missing:** When the skill would use `acli-pii` or `gh` for live data but the tool is not available:
1. Answer from local Lore (knowledge/, logs/, OVERRIDES.md, context/)
2. Then note what couldn't be reached:
   ```
   ℹ Answer from local Lore only. For live data from [Jira/Confluence/GitHub]:
   [specific install command]
   Then retry: /{ALIAS}:ask "$ARGUMENTS"
   ```

## Step 5 — Suggest next steps

After answering, suggest 1–3 contextual follow-up actions based on what was found.

- Blocker identified → "Escalate it? `/{ALIAS}:escalate [blocker]`"
- Stale or wrong information → "Correct it? `/{ALIAS}:overwrite "[wrong]" "[correct]"`"
- Answer is exec-relevant → "Include in the next briefing? `/{ALIAS}:briefing vp`"
- Answer is incomplete → "Dig deeper into a specific area? `/{ALIAS}:ask "[follow-up question]"`"

Max 3. Only suggest what is genuinely useful given the answer.

## Help

```
/{ALIAS}:ask — Query Lore

Usage:  /{ALIAS}:ask [question]

Arguments:
  Any natural language question about the project.

Examples:
  /{ALIAS}:ask "What's the current status of M2?"
  /{ALIAS}:ask "Who owns the NITO workstream?"
  /{ALIAS}:ask "What risks were flagged last week?"
```
