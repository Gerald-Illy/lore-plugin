# /{ALIAS}:note — Save a signal or observation

Arguments: `$ARGUMENTS` (your observation — any text)

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/note/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `note` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the note skill exactly as defined in SKILL.md.
The observation text is: `$ARGUMENTS`

If no argument was provided: ask the user what they want to note.

## Step 5 — Persist

After the note is written:

Ask the user:
> "Note saved locally. Push to the repo so it persists across sessions? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "note: [short description of observation]"
git -C {REPO_PATH} push
```

If push fails (no write access): tell the user:
```
⚠ Could not push. The note is saved locally in ~/.lore/{ALIAS}/
  but will not sync to the shared repo.

  Options:
  a) Ask the repo owner for write access, then run:
     git -C {REPO_PATH} push
  b) Continue working locally — it's safe, just not shared.
```

## Step 6 — Suggest next steps

After saving, suggest 1–3 contextual follow-up actions based on what was captured.

- More observations → "Another? `/{ALIAS}:note [next observation]`"
- This implies a task → "Make it a task? `/{ALIAS}:todo [action]`"
- This might be wrong info → "Correct something? `/{ALIAS}:overwrite "[wrong]" "[correct]"`"

Max 3. Only suggest what is genuinely useful given the context.

## Help

```
/{ALIAS}:note — Save a signal or observation

Usage:  /{ALIAS}:note [text]

Arguments:
  Any observation, signal, or informal intelligence. Saved verbatim.

Examples:
  /{ALIAS}:note Flo mentioned the Telekom timeline is shifting
  /{ALIAS}:note Mat seems overloaded — worth flagging
  /{ALIAS}:note PROJ-123 was mentioned as blocked multiple times
```