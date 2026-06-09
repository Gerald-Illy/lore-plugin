# /{ALIAS}:jot — Quickly capture anything from a session

Arguments: `$ARGUMENTS` (note, todo, feedback, recap, or any text)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/jot/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the jot skill exactly as defined in SKILL.md (or the built-in below).
Pass `$ARGUMENTS` through for type detection and content capture.

If no argument was provided: enter interactive recap mode (summarize full session).

## Step 5 — Persist

If the skill created or modified any files in `{REPO_PATH}`:

Ask the user:
> "Captured. Push to the repo? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "jot: [short description of what was captured]"
git -C {REPO_PATH} push
```

If push fails: tell the user and suggest alternatives.
If no files were created (e.g. user discarded or copied to clipboard only): skip this step.

## Step 6 — Suggest next steps

After the jot flow completes (save/copy/discard), suggest 1–2 contextual follow-ups.

- More to capture → "Another? `/{ALIAS}:jot [text]`"
- Wrong info surfaced → "Correct it? `/{ALIAS}:overwrite "[wrong]" "[correct]"`"
- Session done → "See current state? `/{ALIAS}:briefing leads`"

Max 2. Only suggest what is genuinely useful.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/jot/SKILL.md` does not exist.

### Purpose
Capture notes, todos, feedback, or session recaps into the project repo.

### Type Detection
Detect from the first word of `$ARGUMENTS`:
- `todo` → action item
- `feedback` → quality feedback
- `recap` → session summary
- anything else → general note

### Flow
1. **Determine type** from `$ARGUMENTS` (or ask if empty → recap mode).
2. **Determine target directory:**
   - If `{REPO_PATH}/contributions/` exists → use it
   - Else: create `{REPO_PATH}/notes/`
3. **Write file:**
   - Filename: `[type]-[YYYY-MM-DD]-[short-slug].md`
   - Content: the captured text with a date header
4. **For recap mode** (no args or `recap`):
   - Summarize the current session's key points
   - Write as a dated recap file

### Rules (built-in)
- Never modify existing files — always create new ones
- Always include a date header
- Keep filenames short and descriptive

## Help

```
/{ALIAS}:jot — Quickly capture anything from a session

Usage:
  /{ALIAS}:jot [text]             quick note or observation
  /{ALIAS}:jot todo [text]        action item
  /{ALIAS}:jot feedback [text]    session quality issue
  /{ALIAS}:jot recap [focus]      session summary (full or focused)

Examples:
  /{ALIAS}:jot Flo mentioned Telekom timeline is shifting
  /{ALIAS}:jot todo check with Mat whether M2 date still holds
  /{ALIAS}:jot feedback briefing missed the PS workstream
  /{ALIAS}:jot recap
  /{ALIAS}:jot recap focus on the NITO discussion
```
