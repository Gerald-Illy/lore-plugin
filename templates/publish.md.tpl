# /{ALIAS}:publish — Publish artifact to external platform

Arguments: `$ARGUMENTS` (mode + artifact path, e.g. `page artifacts/briefing.md`)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/publish/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the publish skill exactly as defined in SKILL.md (or the built-in below).
Pass `$ARGUMENTS` for mode and artifact selection.

If no argument was provided: ask the user what they want to publish and where.

## Step 5 — Persist

If any files were created or modified in `{REPO_PATH}`:

Ask the user:
> "Published. Push to the repo? [yes/no]"

If yes:
```bash
git -C {REPO_PATH} add -A
git -C {REPO_PATH} commit -m "publish: [short description]"
git -C {REPO_PATH} push
```

If push fails (no remote or auth issue): tell the user and suggest alternatives.

## Step 6 — Suggest next steps

- Published a briefing → "Share with the team or update: `/{ALIAS}:briefing exec`"
- Published a status → "Keep it updated: re-run after next pull"
- More to publish → "Another artifact? `/{ALIAS}:publish [mode] [path]`"

Max 2. Only suggest what is directly relevant.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/publish/SKILL.md` does not exist.

### Purpose

Generate a shareable artifact from project intelligence.
Without a full publish skill (e.g. Confluence integration), this produces
a clean markdown file that can be manually shared.

### Modes

| Mode | What it does |
|------|-------------|
| `summary` | Generate a project summary from available knowledge |
| `briefing` | Generate a standalone briefing document |
| `export [file]` | Clean up and format a specific file for sharing |

### Flow

1. **Parse arguments** — determine mode from `$ARGUMENTS`
2. **Gather content:**
   - `summary` → read CLAUDE.md, knowledge/ files, recent logs
   - `briefing` → delegate to briefing skill logic, format as standalone doc
   - `export [file]` → read the specified file, clean formatting
3. **Generate artifact** — write to `{REPO_PATH}/artifacts/[name].md`
   - Strip internal references (file paths, skill commands)
   - Add header with generation date
   - Format for external readability
4. **Report** — show the artifact path and content preview

### Output

```
Artifact generated: artifacts/[name].md

Preview:
[first 20 lines]

To share: copy the file content or push the repo.
To publish to Confluence: install the full publish skill in this project.
```

### Rules (built-in)
- Never include internal file paths in published output
- Never include private/confidential sections in published output
- Always add a generation timestamp
- Format for readability by people without Lore context

## Help

```
/{ALIAS}:publish — Publish artifact to external platform

Usage:  /{ALIAS}:publish [mode] [artifact]

Modes:
  summary              Generate shareable project summary
  briefing             Generate standalone briefing document
  export [file]        Clean and format a file for sharing

Examples:
  /{ALIAS}:publish summary
  /{ALIAS}:publish briefing
  /{ALIAS}:publish export knowledge/roadmap.md

With full skill (Confluence integration):
  /{ALIAS}:publish page artifacts/briefing.md
  /{ALIAS}:publish html artifacts/dashboard.html
```
