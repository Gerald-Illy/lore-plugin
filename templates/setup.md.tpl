# /{ALIAS}:setup — Configure Lore sources and project settings

Arguments: `$ARGUMENTS` (action: add-source, edit-source, remove-source, validate, config, update)

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
- Template sync done → "Create a PR: `cd {REPO_PATH} && git push -u origin <branch>`"

Max 2. Only suggest what is genuinely useful.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/setup/SKILL.md` does not exist.

### Purpose
Interactive configuration of Lore sources and project settings.
Includes template sync to adopt new skills/rules/refs from the upstream lore-template.

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

**`update`:**

Compares this project with the lore-template and offers selective adoption of new/changed framework files.

#### Step A — Verify template exists

```bash
test -d ~/.lore/.template/.git && echo "TEMPLATE_OK" || echo "TEMPLATE_MISSING"
```

If `TEMPLATE_MISSING`:
- Tell the user: "Template repo not found at ~/.lore/.template/. Run this to set it up:"
  ```bash
  git clone https://github.com/Gerald-Illy/lore-template.git ~/.lore/.template
  ```
- **Stop here.**

#### Step B — Pull template (get latest)

```bash
git -C ~/.lore/.template pull --quiet && echo "TEMPLATE_SYNCED" || echo "TEMPLATE_PULL_ERROR"
```

If `TEMPLATE_PULL_ERROR`: warn "Could not pull template. Comparing with local version." Continue.

#### Step C — Create sync branch

```bash
cd {REPO_PATH}
git checkout lore-template-sync-$(date +%Y-%m-%d) 2>/dev/null || git checkout -b lore-template-sync-$(date +%Y-%m-%d)
```

#### Step D — Compare framework files

Compare the following between `~/.lore/.template/` and `{REPO_PATH}/`:

| Scope | Path |
|-------|------|
| Skills | `.claude/skills/**` |
| Rules | `.claude/rules/**` |
| Refs | `.claude/refs/**` |
| Agents | `.claude/agents/**` |
| SOURCES.md | `SOURCES.md` |
| SETUP.md | `SETUP.md` |

**NOT compared** (project-specific): `CLAUDE.md`, `OVERRIDES.md`, `VERSIONLOG.md`, `CHANGELOG.md`, `knowledge/`, `log/`, `.lore/`

For each file, categorize:
- **New:** exists in template, not in project
- **Changed:** exists in both, content differs
- **Identical:** same content
- **Only in project:** exists in project, not in template (informational only)

For **Changed** files: summarize what changed in 1 short line.

#### Step E — Display comparison

```
TEMPLATE SYNC: {ALIAS} ← lore-template
══════════════════════════════════════════════════════════

  New in template (can be added):
  ───────────────────────────────
  .claude/skills/newskill/SKILL.md       Short description
  .claude/refs/new-ref.md                Short description

  Changed in template (can be updated):
  ──────────────────────────────────────
  .claude/refs/pull-framework.md         +114 lines — Source Resolution, Web Handling
  .claude/skills/pull/SKILL.md           +28 lines — web source integration

  Only in project (no action needed):
  ────────────────────────────────────
  .claude/skills/custom/SKILL.md         (project-specific)

  Identical: N files

══════════════════════════════════════════════════════════
```

If nothing new or changed:
- Tell the user: "Project is already in sync with the template."
- Switch back to main: `git checkout main`
- **Stop here.**

Otherwise, ask:
```
What would you like to do?
  1. Apply all new + changed files
  2. Select specific files to update
  3. Show detailed diff for a file
  4. Abort (switch back to main, delete branch)
```

#### Step F — Apply changes

For each approved file:
```bash
mkdir -p {REPO_PATH}/$(dirname <relative-path>)
cp ~/.lore/.template/<relative-path> {REPO_PATH}/<relative-path>
```

After all files copied:
```bash
cd {REPO_PATH}
git add -A
git commit -m "sync: apply lore-template updates (<short summary>)"
```

#### Step G — Summary

```
TEMPLATE SYNC COMPLETE
══════════════════════════════════════════════════════════

  Branch:   lore-template-sync-YYYY-MM-DD
  Files:    N new, M changed

  Next:
    Push + PR:  git push -u origin lore-template-sync-YYYY-MM-DD
    Merge now:  git checkout main && git merge lore-template-sync-YYYY-MM-DD
    Rollback:   git checkout main && git branch -D lore-template-sync-YYYY-MM-DD
══════════════════════════════════════════════════════════
```

### Rules (built-in)
- Never overwrite existing SOURCES.md content — only append (for add-source)
- Always confirm before writing changes
- Template sync never touches project-specific files (CLAUDE.md, knowledge/, log/)
- Template sync always works on a branch — never directly on main

## Help

```
/{ALIAS}:setup — Configure Lore sources and project settings

Usage:
  /{ALIAS}:setup                       show current setup status
  /{ALIAS}:setup add-source            add a new source (guided wizard)
  /{ALIAS}:setup edit-source           modify an existing source
  /{ALIAS}:setup remove-source         remove a source
  /{ALIAS}:setup validate              test connectivity to all sources
  /{ALIAS}:setup config                edit project config settings
  /{ALIAS}:setup update                 sync skills/rules/refs from lore-template

Examples:
  /{ALIAS}:setup
  /{ALIAS}:setup add-source jira
  /{ALIAS}:setup validate
  /{ALIAS}:setup update

Tip: After adding a source, run /pull inside the repo to fetch data.
     Use update to adopt new skills from the upstream template.
```
