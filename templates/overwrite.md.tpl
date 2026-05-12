# /{ALIAS}:overwrite — Correct wrong information
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`
Format: `"[wrong information]" "[correct information]"`
Example: `/{ALIAS}:overwrite "M3 deadline is June 15" "M3 deadline is July 1 — confirmed by VP 2026-05-07"`

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

Check if `{REPO_PATH}/.claude/skills/override/SKILL.md` exists.

If it does **not** exist:
- Tell the user: "The `override` skill is not available. Pull the latest: `git -C {REPO_PATH} pull`"
- **Stop here.**

If it exists: read it completely.

## Step 4 — Execute

Execute the override skill exactly as defined in SKILL.md.
Parse `$ARGUMENTS` as two quoted strings: `"[wrong]"` and `"[correct]"`.

If fewer than two quoted strings are provided: ask the user to provide both — what's wrong and what's correct.

After writing the correction to `OVERRIDES.md`:
- Show the user exactly what was written
- Ask for confirmation before committing

## Step 5 — Persist and fix at source

After the override is written to `OVERRIDES.md`:

**Commit and push (if the user has write access):**

Ask the user:
> "Override recorded locally. Push to the repo so it persists across sessions and for all users who share this Lore instance? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add OVERRIDES.md
git -C {REPO_PATH} commit -m "override: [short description of correction]"
git -C {REPO_PATH} push
```

If push fails (no write access): tell the user:
```
⚠ Could not push. The override is saved locally in ~/.lore/{ALIAS}/OVERRIDES.md
  but will not sync to the shared repo.

  Options:
  a) Fix it at the source directly — find where the wrong info came from and correct it there.
     Then escalate to get the source updated: /{ALIAS}:escalate "[what needs to be fixed in source]"
  b) Ask the repo owner for write access, then run:
     git -C {REPO_PATH} push
```

## Step 6 — Suggest next steps

After the override:

- If the error comes from a specific Jira item or Confluence page → "Fix it at the source? `/{ALIAS}:escalate \"Fix [item] — it contains wrong information about [topic]\"`"
- If this changes something in a current briefing → "Regenerate the briefing with correct data: `/{ALIAS}:briefing vp`"
- If this is a systemic data quality issue → "Surface all contradictions: `/{ALIAS}:ask \"What other information may be wrong about [topic]?\"`"

Max 3. Only suggest what is directly relevant.
