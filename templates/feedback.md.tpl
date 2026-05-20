# /{ALIAS}:feedback — Report a session quality issue

Arguments: `$ARGUMENTS` (what went wrong — any text)

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/feedback/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `feedback` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the feedback skill exactly as defined in SKILL.md.
The feedback text is: `$ARGUMENTS`

If no argument was provided: ask the user what went wrong.

## Step 5 — Persist

After the feedback is written:

Ask the user:
> "Feedback saved locally. Push to the repo so it persists across sessions? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "feedback: [short description of issue]"
git -C {REPO_PATH} push
```

If push fails (no write access): tell the user:
```
⚠ Could not push. The feedback is saved locally in ~/.lore/{ALIAS}/
  but will not sync to the shared repo.

  Options:
  a) Ask the repo owner for write access, then run:
     git -C {REPO_PATH} push
  b) Continue working locally — it's safe, just not shared.
```

## Step 6 — Suggest next steps

After saving, suggest 1–3 contextual follow-up actions based on what was reported.

- Want to correct wrong data → "Fix it now? `/{ALIAS}:overwrite "[wrong]" "[correct]"`"
- Want to retry the failed command → "Try again? `/{ALIAS}:[command that failed]`"
- Done for now → "Check overall state? `/{ALIAS}:briefing leads`"

Max 3. Only suggest what is genuinely useful given the feedback.

## Help

```
/{ALIAS}:feedback — Report a session quality issue

Usage:  /{ALIAS}:feedback [text]

Arguments:
  What went wrong or was confusing. Saved with session context.

Examples:
  /{ALIAS}:feedback session showed wrong milestone data for M2
  /{ALIAS}:feedback briefing completely ignored the PS workstream
  /{ALIAS}:feedback answers were too long and unfocused
```