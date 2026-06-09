# /{ALIAS}:overwrite — Correct wrong information

Arguments: `$ARGUMENTS`
Format: `"[wrong information]" "[correct information]"`
Example: `/{ALIAS}:overwrite "M3 deadline is June 15" "M3 deadline is July 1 — confirmed by VP 2026-05-07"`

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/override/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the override skill exactly as defined in SKILL.md (or the built-in below).
Parse `$ARGUMENTS` as two quoted strings: `"[wrong]"` and `"[correct]"`.

If fewer than two quoted strings are provided: ask the user to provide both — what's wrong and what's correct.

## Step 5 — Persist

After the override is written to `OVERRIDES.md`:

Ask the user:
> "Override recorded. Push to the repo? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add OVERRIDES.md
git -C {REPO_PATH} commit -m "override: [short description of correction]"
git -C {REPO_PATH} push
```

If push fails: tell the user and suggest alternatives.

## Step 6 — Suggest next steps

- If the error comes from a source → "Fix at source? `/{ALIAS}:escalate "Fix [item]"`"
- If this changes a briefing → "Regenerate: `/{ALIAS}:briefing vp`"
- Data quality issue → "Check more: `/{ALIAS}:ask "What else may be wrong about [topic]?"`"

Max 3. Only suggest what is directly relevant.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/override/SKILL.md` does not exist.

### Purpose
Record a human correction in OVERRIDES.md so it takes priority over all other data.

### Flow
1. **Parse input** — extract `"[wrong]"` and `"[correct]"` from `$ARGUMENTS`.
2. **Check** if `{REPO_PATH}/OVERRIDES.md` exists. If not, create it with a header:
   ```markdown
   # Overrides
   Human corrections — these always take priority over source data.
   ```
3. **Append** the correction:
   ```markdown
   ## [Short topic] — [today's date]
   - **Wrong:** [wrong information]
   - **Correct:** [correct information]
   - **Source:** Human override
   ```
4. **Confirm** what was written.

### Rules (built-in)
- Never modify existing overrides — only append
- Always include the date
- Present for user confirmation before writing

## Help

```
/{ALIAS}:overwrite — Correct wrong information

Usage:  /{ALIAS}:overwrite "[wrong]" "[correct]"

Arguments:
  Two quoted strings: what's wrong, then what's correct.

Examples:
  /{ALIAS}:overwrite "M3 deadline is June 15" "M3 deadline is July 1 — confirmed by VP 2026-05-07"
  /{ALIAS}:overwrite "NITO owner is Mat" "NITO owner is Flo since 2026-05"
```
