# /{ALIAS}:escalate — Draft Escalation
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS` (Jira ID or plain description of what to escalate)

## Step 1 — Sync the repo

Run:
```bash
git -C {REPO_PATH} pull --quiet 2>/dev/null || echo "REPO_MISSING"
```

If the output contains `REPO_MISSING`:
- Tell the user: "The Lore repo for `{ALIAS}` is not found locally. Reconnect with: `/lore:setup {REPO_URL} {ALIAS}`"
- **Stop here. Do not continue.**

## Step 2 — Load identity

Read `{REPO_PATH}/CLAUDE.md` and internalize it fully.
All rules and behavioral guidelines defined there apply for this session.

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

- Related blocker exists → "Bundle it? `/{ALIAS}:escalate \"[related item]\"`"
- Context is unclear → "Understand the history first? `/{ALIAS}:ask \"What's the history of [item]?\"`"
- Escalation touches a risk → "Check the trend? `/{ALIAS}:ask \"What's the trend on [risk]?\"`"
- Leadership should be briefed after resolution → "Plan the follow-up: `/{ALIAS}:briefing vp`"
- Wrong info at the source → "Correct it: `/{ALIAS}:overwrite \"[wrong]\" \"[correct]\"`"

Max 3. Pick what's most actionable given the situation.
