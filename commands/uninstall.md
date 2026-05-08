# /lore:uninstall — Remove Lore projects and/or the framework
# Powered by Lore — agentic intelligence graph and delivery engine

Arguments: `$ARGUMENTS`
Format: `<alias>` | `--all`

- `<alias>` → remove one connected project (commands + local clone + config entry)
- `--all` → remove all projects + the framework itself (full uninstall)

---

## Step 1 — Verify there is something to uninstall

Run:
```bash
test -d ~/.lore/.plugin/.git && echo "PLUGIN_OK" || echo "PLUGIN_MISSING"
test -d ~/.claude/commands/lore && echo "COMMANDS_OK" || echo "COMMANDS_MISSING"
```

If both return `MISSING`:
- Tell the user: "Lore does not appear to be installed — nothing to uninstall."
- **Stop here.**

If only `PLUGIN_MISSING` (marketplace install without `/lore:setup`): continue — commands still need to be removed.

---

## Step 2 — Parse arguments

If no arguments given: tell the user:
```
Usage:
  /lore:uninstall <alias>    Remove a single connected project
  /lore:uninstall --all      Remove all projects + the Lore framework (full uninstall)
```
**Stop here.**

---

## Step 3 — Confirm before proceeding

For `<alias>`:
- Ask: "This will remove the /<alias>:* commands and delete ~/.lore/<alias>/. Continue? (yes/no)"

For `--all`:
- Ask: "This will remove ALL connected projects, the /lore:* commands, and delete ~/.lore/ entirely. This cannot be undone. Continue? (yes/no)"

If the user says anything other than `yes`: **Stop here.**

---

## Step 4a — Remove a single project (if `<alias>`)

Read `~/.lore/config.json`. If the alias is not found:
- Tell the user: "Project '<alias>' is not registered in Lore. Nothing to remove."
- Check if `~/.claude/commands/<alias>/` exists anyway and offer to remove it.
- **Stop here.**

Remove the project commands:
```bash
rm -rf ~/.claude/commands/<ALIAS>
```

Remove the local clone:
```bash
rm -rf ~/.lore/<ALIAS>
```

Remove the entry from `~/.lore/config.json`:
- Read the file, delete the `<ALIAS>` key from `projects`, write back.
- If `projects` is now empty, write `{}`.

Tell the user:
```
✅ Project '<alias>' removed.

   Deleted: ~/.claude/commands/<alias>/
   Deleted: ~/.lore/<alias>/
   Removed from: ~/.lore/config.json

Remaining projects: <list remaining aliases, or "none">
```

**Stop here.**

---

## Step 4b — Full uninstall (if `--all`)

### Remove all project commands and clones

Read `~/.lore/config.json`. For each alias in `projects`:
```bash
rm -rf ~/.claude/commands/<ALIAS>
echo "Removed: ~/.claude/commands/<ALIAS>/"
```
```bash
rm -rf ~/.lore/<ALIAS>
echo "Removed: ~/.lore/<ALIAS>/"
```

### Remove the /lore framework commands

```bash
rm -rf ~/.claude/commands/lore
echo "Removed: ~/.claude/commands/lore/"
```

### Remove the framework and the entire ~/.lore directory

```bash
rm -rf ~/.lore
echo "Removed: ~/.lore/"
```

---

## Step 5 — Confirm (--all only)

Tell the user:

```
✅ Lore fully uninstalled.

   Removed projects:   <list of aliases, or "none">
   Removed commands:   ~/.claude/commands/lore/
                       ~/.claude/commands/<alias>/ (for each project)
   Removed:            ~/.lore/

To reinstall:
  Mac/Linux:  bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore-plugin/master/setup.sh)
  Windows:    irm https://raw.githubusercontent.com/Gerald-Illy/lore-plugin/master/setup.ps1 | iex
```

Note: the /lore:* commands are still registered in Claude Code's session memory until restart.
Tell the user to restart Claude Code to complete the removal.
