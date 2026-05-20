# /{ALIAS}:recap — Summarize this session and offer to save

Arguments: `$ARGUMENTS` (optional focus topic)

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/recap/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `recap` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the recap skill exactly as defined in SKILL.md.
The focus topic is: `$ARGUMENTS`

If no argument was provided: summarize the full session.

## Step 5 — Persist

After the recap is written:

Ask the user:
> "Recap saved locally. Push to the repo so it persists across sessions? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "recap: [short description of session summary]"
git -C {REPO_PATH} push
```

If push fails (no write access): tell the user:
```
⚠ Could not push. The recap is saved locally in ~/.lore/{ALIAS}/
  but will not sync to the shared repo.

  Options:
  a) Ask the repo owner for write access, then run:
     git -C {REPO_PATH} push
  b) Continue working locally — it's safe, just not shared.
```

## Step 6 — Suggest next steps

After the recap is handled (saved or skipped), suggest 1–3 contextual follow-up actions.

- Something needs correcting → "Fix it? `/{ALIAS}:overwrite "[wrong]" "[correct]"`"
- Open questions surfaced → "Dig deeper? `/{ALIAS}:ask [question]`"
- Tasks identified → "Capture a task? `/{ALIAS}:todo [task]`"
- Session is done → "See the big picture? `/{ALIAS}:briefing leads`"

Max 3. Only suggest what is genuinely useful given the recap.
