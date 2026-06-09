# /{ALIAS}:briefing — Stakeholder Briefing

Arguments: `$ARGUMENTS` (expected: `exec`, `vp`, or `leads`)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/briefing/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the briefing skill exactly as defined in SKILL.md (or the built-in below).
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

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/briefing/SKILL.md` does not exist.

### Purpose
Generate a project status briefing from available local files.

### Flow
1. **Read all available context:**
   - `{REPO_PATH}/CLAUDE.md` (project identity)
   - `{REPO_PATH}/OVERRIDES.md` (corrections, if exists)
   - All files in `{REPO_PATH}/knowledge/` (if exists)
   - Last 7 days of `{REPO_PATH}/log/daily/` (if exists)
   - `{REPO_PATH}/README.md` (if exists)
   - Recent git log: `git -C {REPO_PATH} log --oneline -20`
2. **Determine audience** from `$ARGUMENTS` (exec/vp/leads):
   - `exec` — strategic only: key decisions, top risks, milestone status
   - `vp` — full picture: all workstreams, dependencies, timeline
   - `leads` — operational: what's happening today, blockers, actions
3. **Generate briefing** with:
   - Current state summary
   - Open risks (if any found)
   - Recent changes
   - Open decisions or blockers
4. **Mark gaps** — clearly state what data is missing or potentially stale.

### Output Format
```
# Briefing: {ALIAS} — [audience level]
Date: [today]

## Current State
[summary]

## Risks & Blockers
[list or "None identified"]

## Recent Changes
[from logs/git]

## Open Items
[decisions, actions]

---
Source: local project files | Last pull: [date of newest log]
```

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
