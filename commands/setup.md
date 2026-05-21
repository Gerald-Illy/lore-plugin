# /lore:setup — Connect a project repo to Lore
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`
Format: `<repo-url> <alias>`
Examples:
- `/lore:setup github:YourOrg/YourProject myproject`
- `/lore:setup https://github.com/YourOrg/YourProject.git myproject`

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
```

---

## Step 3 — Clone or update the project repo

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
      "installed": "<YYYY-MM-DD today>"
    }
  }
}
```

Write back to `~/.lore/config.json`.

---

## Step 8 — Confirm

Tell the user:

```
✅ Lore project connected: <ALIAS>

   Repo:      <REPO_URL>
   Local:     ~/.lore/<ALIAS>
   Commands:  /<ALIAS>:briefing   /<ALIAS>:ask   /<ALIAS>:escalate   /<ALIAS>:overwrite
              /<ALIAS>:jot   /<ALIAS>:help

To remove this project: /lore:uninstall <ALIAS>
To remove everything:   /lore:uninstall --all

Try it now: /<ALIAS>:briefing leads
```

Suggest exactly one starting command. Default to `/<ALIAS>:briefing leads` unless the repo has a different suggested entry point in its CLAUDE.md.
