# /{ALIAS}:todo — Drop a task for the delivery lead

Arguments: `$ARGUMENTS` (your task — any text)

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/todo/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `todo` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the todo skill exactly as defined in SKILL.md.
The task text is: `$ARGUMENTS`

If no argument was provided: ask the user what task they want to capture.

## Step 5 — Persist

After the task is written:

Ask the user:
> "Task saved locally. Push to the repo so it persists across sessions? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "todo: [short description of task]"
git -C {REPO_PATH} push
```

If push fails (no write access): tell the user:
```
⚠ Could not push. The task is saved locally in ~/.lore/{ALIAS}/
  but will not sync to the shared repo.

  Options:
  a) Ask the repo owner for write access, then run:
     git -C {REPO_PATH} push
  b) Continue working locally — it's safe, just not shared.
```

## Step 6 — Suggest next steps

After saving, suggest 1–3 contextual follow-up actions based on what was captured.

- More tasks to drop → "Another one? `/{ALIAS}:todo [next task]`"
- Want to add context → "Add a note? `/{ALIAS}:note [observation]`"
- Done with input → "See current state? `/{ALIAS}:briefing leads`"

Max 3. Only suggest what is genuinely useful given the context.

## Help

```
/{ALIAS}:todo — Drop a task for the delivery lead

Usage:  /{ALIAS}:todo [text]

Arguments:
  Any text describing the task. Saved verbatim.

Examples:
  /{ALIAS}:todo make sure NITO config is documented
  /{ALIAS}:todo check with Mat whether the M2 date still holds
  /{ALIAS}:todo review the inconsistencies from last pull
```