# /{ALIAS}:setup — Configure Lore sources and project settings

Arguments: `$ARGUMENTS` (action: add-source, edit-source, remove-source, validate, config)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/setup/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the setup skill exactly as defined in SKILL.md (or the built-in below).
Pass `$ARGUMENTS` through for action routing.

If no argument was provided: show current setup status (sources configured, what's missing).

## Step 5 — Persist

If the skill created or modified any files in `{REPO_PATH}`:

Ask the user:
> "Configuration updated. Push to the repo? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "setup: [short description of what was configured]"
git -C {REPO_PATH} push
```

If push fails: tell the user and suggest alternatives.
If no files were created: skip this step.

## Step 6 — Suggest next steps

After the setup flow completes, suggest 1–2 contextual follow-ups:

- Source added → "Pull data now? `/{ALIAS}:ask what sources are configured?`" or "Run first pull inside the repo: `cd ~/.lore/{ALIAS}` then `/pull onboarding`"
- Validation failed → "Fix the source: `/{ALIAS}:setup edit-source`"
- All sources healthy → "Ready to pull? Work inside the repo: `cd ~/.lore/{ALIAS}` then `/pull`"

Max 2. Only suggest what is genuinely useful.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/setup/SKILL.md` does not exist.

### Purpose
Interactive configuration of Lore sources and project settings.

### Actions

**No argument (status):**
1. Read `{REPO_PATH}/SOURCES.md`
2. Check which source types are configured (Jira, Confluence, GitHub, Web, SharePoint)
3. Check `.lore/config.md` exists and has content
4. Display status summary

**`add-source`:**
1. Ask user for source type (Jira, Confluence, GitHub, Web, SharePoint)
2. Collect type-specific details (URL, project key, etc.)
3. Append to `{REPO_PATH}/SOURCES.md` in the correct format

**`validate`:**
1. Read `{REPO_PATH}/SOURCES.md`
2. For each source: attempt to verify connectivity
3. Report results

### Rules (built-in)
- Never overwrite existing SOURCES.md content — only append
- Always confirm before writing changes
- If a source type section already exists, add to it (don't duplicate headings)

## Help

```
/{ALIAS}:setup — Configure Lore sources and project settings

Usage:
  /{ALIAS}:setup                    show current setup status
  /{ALIAS}:setup add-source         add a new source (guided wizard)
  /{ALIAS}:setup edit-source        modify an existing source
  /{ALIAS}:setup remove-source      remove a source
  /{ALIAS}:setup validate           test connectivity to all sources
  /{ALIAS}:setup config             edit project config settings

Examples:
  /{ALIAS}:setup
  /{ALIAS}:setup add-source
  /{ALIAS}:setup add-source jira
  /{ALIAS}:setup validate

Tip: After adding a source, run /pull inside the repo to fetch data.
```
