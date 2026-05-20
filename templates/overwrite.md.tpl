# /{ALIAS}:overwrite — Correct wrong information

Arguments: `$ARGUMENTS`
Format: `"[wrong information]" "[correct information]"`
Example: `/{ALIAS}:overwrite "M3 deadline is June 15" "M3 deadline is July 1 — confirmed by VP 2026-05-07"`

## Step 0 — Help check

If `$ARGUMENTS` is exactly `--help` or `-h`:
1. Sync the repo first (run the git pull from Step 1 so paths are available)
2. Find the skill path referenced in Step 3 of this file (e.g. `{REPO_PATH}/.claude/skills/override/SKILL.md`)
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

Check if `{REPO_PATH}/.claude/skills/override/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `override` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the override skill exactly as defined in SKILL.md.
Parse `$ARGUMENTS` as two quoted strings: `"[wrong]"` and `"[correct]"`.

If fewer than two quoted strings are provided: ask the user to provide both — what's wrong and what's correct.

After writing the correction to `OVERRIDES.md`:
- Show the user exactly what was written
- Ask for confirmation before committing

## Step 5 — Persist and fix at source

After the override is written to `OVERRIDES.md`:

**Commit and push (if the user has write access):**

Ask the user:
> "Override recorded locally. Push to the repo so it persists across sessions and for all users who share this Lore instance? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add OVERRIDES.md
git -C {REPO_PATH} commit -m "override: [short description of correction]"
git -C {REPO_PATH} push
```

If push fails (no write access): tell the user:
```
⚠ Could not push. The override is saved locally in ~/.lore/{ALIAS}/OVERRIDES.md
  but will not sync to the shared repo.

  Options:
  a) Fix it at the source directly — find where the wrong info came from and correct it there.
     Then escalate to get the source updated: /{ALIAS}:escalate "[what needs to be fixed in source]"
  b) Ask the repo owner for write access, then run:
     git -C {REPO_PATH} push
```

## Step 6 — Suggest next steps

After the override:

- If the error comes from a specific Jira item or Confluence page → "Fix it at the source? `/{ALIAS}:escalate "Fix [item] — it contains wrong information about [topic]"`"
- If this changes something in a current briefing → "Regenerate the briefing with correct data: `/{ALIAS}:briefing vp`"
- If this is a systemic data quality issue → "Surface all contradictions: `/{ALIAS}:ask "What other information may be wrong about [topic]?"`"

Max 3. Only suggest what is directly relevant.

## Help

```
/{ALIAS}:overwrite — Correct wrong information

Usage:  /{ALIAS}:overwrite "[wrong]" "[correct]"

Arguments:
  Two quoted strings: what's wrong, then what's correct.

Examples:
  /{ALIAS}:overwrite "M3 deadline is June 15" "M3 deadline is July 1 — confirmed by VP 2026-05-07"
  /{ALIAS}:overwrite "NITO owner is Mat" "NITO owner is Flo since 2026-05"
```
