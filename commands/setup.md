# /lore:setup — Connect a project repo to Lore
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`
Format: `<repo-url> <alias>`
Examples:
- `/lore:setup github:YourOrg/YourProject myproject`
- `/lore:setup https://github.com/YourOrg/YourProject.git myproject`

---

## Step 1 — Verify the Lore framework

Run:
```bash
test -d ~/.lore/.git && echo "OK" || echo "MISSING"
```

If `MISSING`:
- Tell the user: "Lore is not installed yet. Run the setup script first:"
  ```
  Mac/Linux:  bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.sh)
  Windows:    irm https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.ps1 | iex
  ```
- **Stop here. Do not continue.**

---

## Step 2 — Parse arguments

Parse `$ARGUMENTS` into two tokens:

- **REPO_URL** (first token):
  - If it starts with `github:Owner/Repo` → convert to `https://github.com/Owner/Repo.git`
  - If it starts with `https://` → use as-is
- **ALIAS** (second token): lowercase short name, no spaces (e.g. `work`, `kb`)

If either token is missing: ask the user to provide it before continuing. **Stop until both are provided.**

Set:
```
REPO_URL  = <parsed>
ALIAS     = <parsed, lowercase>
REPO_PATH = ~/.lore/<ALIAS>
PLUGIN_PATH = ~/.lore/<ALIAS>/.lore-plugin
```

---

## Step 3 — Clone or update the project repo

Run:
```bash
if [ -d "$HOME/.lore/$ALIAS/.git" ]; then
  git -C ~/.lore/$ALIAS pull --quiet && echo "UPDATED"
else
  mkdir -p ~/.lore
  git clone $REPO_URL ~/.lore/$ALIAS && echo "CLONED"
fi
```

If this fails:
- If the repo is private: tell the user to run `gh auth login` first, then retry `/lore:setup`.
- If the URL looks wrong: show the URL that was attempted and ask the user to verify it.
- **Stop here if clone failed.**

---

## Step 4 — Verify Lore compatibility

Check:
```bash
test -f ~/.lore/$ALIAS/CLAUDE.md && echo "HAS_CLAUDE_MD" || echo "NO_CLAUDE_MD"
test -d ~/.lore/$ALIAS/.claude/skills && echo "HAS_SKILLS" || echo "NO_SKILLS"
```

- If `NO_CLAUDE_MD`: warn — "This repo has no `CLAUDE.md`. Commands will run but Claude will have no project identity." Continue anyway.
- If `NO_SKILLS`: warn — "This repo has no `.claude/skills/`. Skill execution commands will fail." Continue anyway.

---

## Step 5 — Generate the project plugin from templates

The templates live at `~/.lore/templates/`.

For each template file, read it, replace all placeholder tokens, and write the result directly to Claude Code's global commands directory for this alias.

**Substitution tokens:**
- `{ALIAS}` → the actual alias value (e.g. `myproject`)
- `{REPO_URL}` → the full repo URL (e.g. `https://github.com/YourOrg/YourProject.git`)
- `{REPO_PATH}` → `~/.lore/<ALIAS>` (with alias substituted, NOT expanded)

**Create directory:**
```bash
mkdir -p ~/.claude/commands/$ALIAS
```

**File mapping — read from template, write to target:**

| Template source | Target path |
|----------------|-------------|
| `~/.lore/templates/briefing.md.tpl` | `~/.claude/commands/$ALIAS/briefing.md` |
| `~/.lore/templates/ask.md.tpl` | `~/.claude/commands/$ALIAS/ask.md` |
| `~/.lore/templates/escalate.md.tpl` | `~/.claude/commands/$ALIAS/escalate.md` |
| `~/.lore/templates/overwrite.md.tpl` | `~/.claude/commands/$ALIAS/overwrite.md` |
| `~/.lore/templates/help.md.tpl` | `~/.claude/commands/$ALIAS/help.md` |

After writing each file, confirm: `echo "Written: <path>"`

---

## Step 6 — Register the project in Lore config

Read `~/.lore/config.json` (if it does not exist, start with `{}`).

Add or update the entry for this alias:
```json
{
  "projects": {
    "<ALIAS>": {
      "repo": "<REPO_URL>",
      "path": "~/.lore/<ALIAS>",
      "installed": "<YYYY-MM-DD today>"
    }
  }
}
```

Write back to `~/.lore/config.json`.

---

## Step 7 — Confirm

Tell the user:

```
✅ Lore project connected: <ALIAS>

   Repo:      <REPO_URL>
   Local:     ~/.lore/<ALIAS>
   Commands:  /<ALIAS>:briefing   /<ALIAS>:ask   /<ALIAS>:escalate   /<ALIAS>:overwrite   /<ALIAS>:help

Try it now: /<ALIAS>:briefing leads
```

Suggest exactly one starting command. Default to `/<ALIAS>:briefing leads` unless the repo has a different suggested entry point in its CLAUDE.md.
