# /{ALIAS}:briefing — Stakeholder Briefing

Arguments: `$ARGUMENTS` (expected: `exec`, `vp`, or `leads`)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

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
- Decisions pending → "Dig deeper? `/{ALIAS}:ask "What's blocking [decision]?"`"
- Thin data on a workstream → "Check it? `/{ALIAS}:ask "Status of [workstream]?"`"
- All clear → "Prep next level up: `/{ALIAS}:briefing vp`"

Phrase as copy-pasteable commands. Max 3. Pick what's most actionable.

## Help

```
/{ALIAS}:briefing — Stakeholder Briefing

Usage:  /{ALIAS}:briefing [audience]

Arguments:
  exec     C-Level strategic summary
  vp       VP-level full project view
  leads    Delivery lead operational view (default)

Examples:
  /{ALIAS}:briefing leads
  /{ALIAS}:briefing vp
  /{ALIAS}:briefing exec
```
