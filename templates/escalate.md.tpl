# /{ALIAS}:escalate — Draft Escalation

Arguments: `$ARGUMENTS` (Jira ID or plain description of what to escalate)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/escalate/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the escalate skill exactly as defined in SKILL.md (or the built-in below).
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

- Context is unclear → "Understand the history? `/{ALIAS}:ask "What's the history of [item]?"`"
- Leadership should be briefed → "Plan the follow-up: `/{ALIAS}:briefing vp`"
- Wrong info at the source → "Correct it: `/{ALIAS}:overwrite "[wrong]" "[correct]"`"

Max 3. Pick what's most actionable given the situation.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/escalate/SKILL.md` does not exist.

### Purpose
Draft a structured escalation message from available project context.

### Flow
1. **Understand the target** — what is being escalated? Parse from `$ARGUMENTS`.
2. **Gather context** from:
   - `{REPO_PATH}/knowledge/` (relevant files)
   - `{REPO_PATH}/OVERRIDES.md`
   - `{REPO_PATH}/log/daily/` (recent mentions)
   - Recent git log for related changes
3. **Draft escalation** with:
   - **What:** Clear description of the issue
   - **Why now:** What makes this urgent
   - **Impact:** What happens if not addressed
   - **Ask:** What action is needed from the recipient
   - **Context:** Links/references to supporting information
4. **Present** the draft for user review and editing.

### Rules (built-in)
- Never invent context not found in available files
- Always present as a draft — user must review before sending
- Include source references for all claims

## Help

```
/{ALIAS}:escalate — Draft Escalation

Usage:  /{ALIAS}:escalate [ID or description]

Arguments:
  A Jira ticket ID or plain text description of what to escalate.

Examples:
  /{ALIAS}:escalate PROJ-1234
  /{ALIAS}:escalate "M2 deadline at risk due to dependency on Team X"
  /{ALIAS}:escalate "No owner assigned to the auth migration"
```
