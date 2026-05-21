# /{ALIAS}:overwrite — Correct wrong information

Arguments: `$ARGUMENTS`
Format: `"[wrong information]" "[correct information]"`
Example: `/{ALIAS}:overwrite "M3 deadline is June 15" "M3 deadline is July 1 — confirmed by VP 2026-05-07"`

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

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
