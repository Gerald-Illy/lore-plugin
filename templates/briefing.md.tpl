# /{ALIAS}:briefing — Stakeholder Briefing
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS` (expected: `exec`, `vp`, or `leads`)

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
- `{REPO_PATH}/.claude/rules/tagging.md`
- `{REPO_PATH}/.claude/rules/ai-inference.md`

**Load corrections and learnings:**
- `{REPO_PATH}/OVERRIDES.md`
- `{REPO_PATH}/.lore/agent-learning.md`

If any file does not exist, skip it silently and continue.

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/briefing/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `briefing` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the briefing skill exactly as defined in SKILL.md.
Pass `$ARGUMENTS` as the audience parameter. If no argument was provided, default to `leads`.

**If a CLI tool is missing:** When the skill needs `acli-pii` (Jira/Confluence) or `gh` (GitHub) but the tool is not available:
1. Complete the briefing with what you CAN access (knowledge/, logs/, OVERRIDES.md)
2. Then note:
   ```
   ℹ Briefing from local Lore only. For live source data, install:
   [specific install command]
   Then retry: /{ALIAS}:briefing $ARGUMENTS
   ```

## Step 5 — Suggest next steps

After the briefing, suggest 2–3 contextual follow-up actions based on what surfaced.

- Risks surfaced → "Escalate one? `/{ALIAS}:escalate [risk]`"
- Decisions pending → "Dig deeper? `/{ALIAS}:ask \"What's blocking [decision]?\"`"
- Thin data on a workstream → "Check it? `/{ALIAS}:ask \"Status of [workstream]?\"`"
- All clear → "Prep next level up: `/{ALIAS}:briefing vp`"

Phrase as copy-pasteable commands. Max 3. Pick what's most actionable.
