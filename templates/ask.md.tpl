# /{ALIAS}:ask — Query Lore

Arguments: `$ARGUMENTS` (your question — any natural language)

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
