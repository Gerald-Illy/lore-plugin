# /{ALIAS}:ask — Query Lore

Arguments: `$ARGUMENTS` (your question — any natural language)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/ask/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the ask skill exactly as defined in SKILL.md (or the built-in below).
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
- Answer is incomplete → "Dig deeper? `/{ALIAS}:ask "[follow-up question]"`"

Max 3. Only suggest what is genuinely useful given the answer.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/ask/SKILL.md` does not exist.

### Purpose
Answer questions about the project from available local files.

### Flow
1. **Search for relevant content** across:
   - `{REPO_PATH}/knowledge/` (all .md files)
   - `{REPO_PATH}/OVERRIDES.md`
   - `{REPO_PATH}/log/daily/` (recent entries)
   - `{REPO_PATH}/CLAUDE.md`
   - `{REPO_PATH}/README.md`
   - Any other .md files in the repo root
2. **Answer the question** from what was found.
3. **Cite sources** — say which file(s) the answer came from.
4. **Acknowledge gaps** — if the question can't be fully answered, say what's missing.

### Rules (built-in)
- Never invent information not found in available files
- OVERRIDES.md has priority over other files
- If the answer contradicts across files, surface both with file references
- If nothing relevant is found: "This is not documented in the available project files."

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
