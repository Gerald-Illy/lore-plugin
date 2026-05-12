# /{ALIAS}:ask — Query Lore
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS` (your question — any natural language)

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
- Stale or wrong information → "Correct it? `/{ALIAS}:overwrite \"[wrong]\" \"[correct]\"`"
- Answer is exec-relevant → "Include in the next briefing? `/{ALIAS}:briefing vp`"
- Answer is incomplete → "Dig deeper into a specific area? `/{ALIAS}:ask \"[follow-up question]\"`"

Max 3. Only suggest what is genuinely useful given the answer.
