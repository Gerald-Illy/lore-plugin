# /{ALIAS}:pull — Pull fresh data from sources into Lore

Arguments: `$ARGUMENTS` (scope: jira, confluence, github, web, journal, onboarding, retroactive)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/pull/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the pull skill exactly as defined in SKILL.md (or the built-in below).
Pass `$ARGUMENTS` through for scope routing.

If no argument was provided: pull all active sources.

## Step 5 — Persist

After the pull completes and files have been created/modified in `{REPO_PATH}`:

Ask the user:
> "Pull complete. Push to the repo? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "pull: [short description of what was pulled]"
git -C {REPO_PATH} push
```

If push fails: tell the user and suggest alternatives.
If no files were created: skip this step.

## Step 6 — Suggest next steps

After the pull flow completes, suggest 1–2 contextual follow-ups:

- Pull succeeded → "See what changed? `/{ALIAS}:briefing leads`"
- Inconsistencies found → "Review conflicts: `/{ALIAS}:ask inconsistencies`"
- First pull (onboarding) → "Check the baseline: `/{ALIAS}:ask what do we know so far?`"

Max 2. Only suggest what is genuinely useful.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/pull/SKILL.md` does not exist.

### Purpose
Pull fresh data from configured sources into Lore's local knowledge store.

### Flow
1. **Read SOURCES.md** to determine active sources
2. **For each source type** attempt to fetch:
   - Jira → use `acli-pii` if available
   - Confluence → use `acli-pii` if available
   - GitHub → use `gh` CLI if available
   - Web → use WebFetch for each URL
3. **Write log entries** to `{REPO_PATH}/log/daily/YYYY-MM-DD.md`
4. **Update manifests** in `{REPO_PATH}/.lore/manifests/`
5. **Run consistency check** if `.claude/refs/consistency-check.md` exists

### Rules (built-in)
- Never invent data — only record what sources actually return
- Never modify sources — read only
- Always run consistency check after pull
- If a CLI tool is missing: note what's missing with the install command, continue with available sources

## Help

```
/{ALIAS}:pull — Pull fresh data from sources into Lore

Usage:
  /{ALIAS}:pull                     all active sources
  /{ALIAS}:pull jira                only Jira
  /{ALIAS}:pull confluence          only Confluence
  /{ALIAS}:pull github              only GitHub
  /{ALIAS}:pull web                 only web sources
  /{ALIAS}:pull onboarding          first pull (establishes baseline)

Examples:
  /{ALIAS}:pull
  /{ALIAS}:pull jira
  /{ALIAS}:pull onboarding

Tip: Run /pull onboarding once after setting up sources.
     Then use /pull daily to keep Lore current.
```
