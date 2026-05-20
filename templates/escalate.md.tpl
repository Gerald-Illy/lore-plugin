# /{ALIAS}:escalate — Draft Escalation

Arguments: `$ARGUMENTS` (Jira ID or plain description of what to escalate)

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/escalate/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `escalate` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the escalate skill exactly as defined in SKILL.md.
The escalation target is: `$ARGUMENTS`

If no argument was provided: ask the user what needs to be escalated (Jira ID or description).

**If a CLI tool is missing:** When the skill would use `acli-pii` or `gh` for live context:
1. Draft the escalation with what you CAN access (knowledge/, logs/, OVERRIDES.md)
2. Then note:
   ```
   ℹ Escalation drafted from local Lore only. For full context from live sources:
   [specific install command]
   Then retry: /{ALIAS}:escalate $ARGUMENTS
   ```

## Step 5 — Suggest next steps

After the escalation draft, suggest 1–3 contextual follow-up actions.

- Related blocker exists → "Bundle it? `/{ALIAS}:escalate "[related item]"`"
- Context is unclear → "Understand the history first? `/{ALIAS}:ask "What's the history of [item]?"`"
- Escalation touches a risk → "Check the trend? `/{ALIAS}:ask "What's the trend on [risk]?"`"
- Leadership should be briefed after resolution → "Plan the follow-up: `/{ALIAS}:briefing vp`"
- Wrong info at the source → "Correct it: `/{ALIAS}:overwrite "[wrong]" "[correct]"`"

Max 3. Pick what's most actionable given the situation.
