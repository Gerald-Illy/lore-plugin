# /lore:setup — Connect or create a Lore project
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`

**Two modes:**

1. **Connect existing repo:** `/lore:setup <repo-url> <alias>`
   - `/lore:setup github:YourOrg/YourProject myproject`
   - `/lore:setup https://github.com/YourOrg/YourProject.git myproject`

2. **Create new project from template:** `/lore:setup new <alias>`
   - `/lore:setup new myproject`
   - Creates a fresh local Lore project from the template (no remote repo needed)

---

## Step 1 — Ensure the Lore framework is present

Run:
```bash
test -d ~/.lore/.plugin/.git && echo "OK" || echo "MISSING"
```

If `MISSING`:
- Tell the user: "Cloning Lore framework to ~/.lore/.plugin/..."
- Run:
  ```bash
  mkdir -p ~/.lore && git clone https://github.com/Gerald-Illy/lore-plugin.git ~/.lore/.plugin && echo "CLONED" || echo "CLONE_FAILED"
  ```
- If `CLONE_FAILED`: tell the user to check their connection or run `gh auth login` if the repo is private. **Stop here.**
- If `CLONED`: continue.

---

## Step 2 — Parse arguments and determine mode

Parse `$ARGUMENTS`:

- **Two tokens:**
  - **If first token is `new`** → Template mode (new project):
    - **ALIAS** (second token): lowercase short name, no spaces (e.g. `work`, `kb`)
    - **REPO_URL** = `local`
    - **MODE** = `template`
  - **Otherwise** → Connect mode (existing repo):
    - **REPO_URL** (first token):
      - If it starts with `github:Owner/Repo` → convert to `https://github.com/Owner/Repo.git`
      - If it starts with `https://` → use as-is
    - **ALIAS** (second token): lowercase short name, no spaces
    - **MODE** = `connect`

- **One token or no tokens** → Error:
  Tell the user:
  ```
  ❌ Invalid arguments. Use one of:
  
     /lore:setup <repo-url> <alias>    (connect existing repo)
     /lore:setup new <alias>            (create from template)
  
  Examples:
     /lore:setup github:YourOrg/Repo myproject
     /lore:setup new myproject
  ```
  **Stop here.**

Set:
```
REPO_URL  = <parsed or "local">
ALIAS     = <parsed, lowercase>
REPO_PATH = ~/.lore/<ALIAS>
MODE      = "connect" or "template"
```

---

## Step 3 — Clone or create the project

### If MODE = "connect" (existing repo):

Run:
```bash
if [ -d "$HOME/.lore/$ALIAS/.git" ]; then
  git -C ~/.lore/$ALIAS pull --quiet && echo "UPDATED"
else
  git clone $REPO_URL ~/.lore/$ALIAS && echo "CLONED"
fi
```

If this fails, check the error output for clues:

- **Access denied / 403 / "Repository not found" / "could not read Username":**
  Tell the user:
  > "You don’t have access to `<REPO_URL>`.
  > Please ask the repository owner to grant you read access, then retry `/lore:setup`."
  **Stop here.**
- **Not authenticated (private repo, no credentials):**
  Tell the user to run `gh auth login` first, then retry `/lore:setup`. **Stop here.**
- **URL looks wrong:** Show the URL that was attempted and ask the user to verify it. **Stop here.**
- Any other error: Show the raw git error message so the user can diagnose it. **Stop here.**

### If MODE = "template" (new project):

Run:
```bash
if [ -d "$HOME/.lore/$ALIAS/.git" ]; then
  echo "ALREADY_EXISTS"
else
  TMPDIR="/tmp/lore-template-$ALIAS"
  rm -rf "$TMPDIR"
  git clone https://github.com/Gerald-Illy/lore-template.git "$TMPDIR" && \
  mkdir -p ~/.lore/$ALIAS && \
  cp -r "$TMPDIR"/. ~/.lore/$ALIAS/ && \
  rm -rf ~/.lore/$ALIAS/.git && \
  find ~/.lore/$ALIAS -type f -name "*.md" -exec sed -i 's/{PROJECT_NAME}/'"$ALIAS"'/g' {} + && \
  git -C ~/.lore/$ALIAS init && \
  git -C ~/.lore/$ALIAS add -A && \
  git -C ~/.lore/$ALIAS commit -m "Initial Lore project: $ALIAS (from template)" && \
  rm -rf "$TMPDIR" && \
  echo "CREATED"
fi
```

Handle:
- **`ALREADY_EXISTS`**: Tell the user: "A project `<ALIAS>` already exists at `~/.lore/<ALIAS>`. To reconnect, provide the repo URL: `/lore:setup <url> <alias>`. To recreate from template, first remove it: `/lore:uninstall <ALIAS>`." **Stop here.**
- **`CREATED`**: Continue.
- **Clone failed**: Tell the user to check their network — the Lore template repo could not be reached. **Stop here.**

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

Run the regeneration script:
```bash
bash ~/.lore/.plugin/scripts/regenerate.sh $ALIAS $REPO_URL
```

This generates all commands from templates + `plugin.json` into `~/.claude/commands/$ALIAS/`.

If the script outputs `REGENERATED:$ALIAS` → success.
If it fails (e.g. templates directory missing): tell the user to run `/lore:update` to restore the plugin, then retry.

---

## Step 6 — Install permissions for the Lore instance

Run:
```bash
mkdir -p ~/.lore/$ALIAS/.claude
sed -e "s|{ALIAS}|$ALIAS|g" \
    -e "s|{REPO_URL}|$REPO_URL|g" \
    -e "s|{REPO_PATH}|~/.lore/$ALIAS|g" \
    ~/.lore/.plugin/templates/settings.json.tpl \
    > ~/.lore/$ALIAS/.claude/settings.json
echo "Written: ~/.lore/$ALIAS/.claude/settings.json"
```

This auto-allows git and file operations on the Lore instance so users don't get prompted for every command.

---

## Step 7 — Register the project in Lore config

Read `~/.lore/config.json` (if it does not exist, start with `{}`).

Add or update the entry for this alias:
```json
{
  "projects": {
    "<ALIAS>": {
      "repo": "<REPO_URL>",
      "path": "~/.lore/<ALIAS>",
      "installed": "<YYYY-MM-DD today>",
      "source": "<MODE>"
    }
  }
}
```

- `"source"` is `"template"` if MODE = template, `"connect"` if MODE = connect.

Write back to `~/.lore/config.json`.

---

## Step 8 — Confirm

### If MODE = "connect":

Tell the user:

```
✅ Lore project connected: <ALIAS>

   Repo:      <REPO_URL>
   Local:     ~/.lore/<ALIAS>
   Commands:  /<ALIAS>:briefing   /<ALIAS>:ask   /<ALIAS>:escalate   /<ALIAS>:overwrite
              /<ALIAS>:jot   /<ALIAS>:reasoning   /<ALIAS>:publish   /<ALIAS>:help

To remove this project: /lore:uninstall <ALIAS>
To remove everything:   /lore:uninstall --all

Try it now: /<ALIAS>:briefing leads
```

Suggest exactly one starting command: `/<ALIAS>:briefing leads` (unless the repo has a different suggested entry point in its CLAUDE.md).

### If MODE = "template":

First, generate a **status report** by checking what's present:

```bash
cd ~/.lore/$ALIAS
echo "=== Structure ==="
echo "CLAUDE.md:       $(test -f CLAUDE.md && echo '✅' || echo '❌')"
echo "SOURCES.md:      $(test -f SOURCES.md && echo '✅' || echo '❌')"
echo "OVERRIDES.md:    $(test -f OVERRIDES.md && echo '✅' || echo '❌')"
echo "knowledge/:      $(test -d knowledge && echo '✅' || echo '❌')"
echo "log/:            $(test -d log && echo '✅' || echo '❌')"
echo ".claude/skills/: $(test -d .claude/skills && echo '✅' || echo '❌')"
echo ".claude/rules/:  $(test -d .claude/rules && echo '✅' || echo '❌')"
echo ".lore/config.md: $(test -f .lore/config.md && echo '✅' || echo '❌')"
echo "=== Placeholders remaining ==="
grep -rl '{PROJECT_NAME}' . --include="*.md" 2>/dev/null | head -5 || echo "None"
echo "=== Sources configured ==="
grep -c 'https://' SOURCES.md 2>/dev/null || echo "0"
```

Then tell the user:

```
✅ Lore project created: <ALIAS>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂 Project Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   Location:   ~/.lore/<ALIAS>
   Source:     template (local only, no remote)
   Project:    {PROJECT_NAME} → <ALIAS> (replaced in all .md files)

   Structure:
   [show results from status check above]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 Next Steps (required)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   1. Configure your sources:
      Open ~/.lore/<ALIAS>/SOURCES.md and add your real URLs
      (Jira, Confluence, GitHub, SharePoint — whatever applies)

   2. Run your first pull:
      /<ALIAS>:ask what sources are configured?

   3. When sources are ready:
      cd ~/.lore/<ALIAS> && /pull onboarding

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Commands installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   /<ALIAS>:briefing   /<ALIAS>:ask   /<ALIAS>:escalate   /<ALIAS>:overwrite
   /<ALIAS>:jot   /<ALIAS>:help

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

To connect a remote later:
   cd ~/.lore/<ALIAS> && git remote add origin <your-repo-url>

To validate setup:
   cd ~/.lore/<ALIAS> && /lore check

To remove this project: /lore:uninstall <ALIAS>
```

After showing the report, **run the template's built-in setup check**:

Read `~/.lore/<ALIAS>/.claude/skills/lore/SKILL.md`. If it exists, execute the `/lore check` action from it (the setup checklist that verifies presence, consistency, and quality). Show the results as part of the status output.

If the skill does not exist, skip this step silently.

Suggest exactly one starting command: `/<ALIAS>:help`
