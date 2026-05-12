# /lore — Lore help
# Powered by Lore — agentic intelligence graph and delivery engine

---

## Update check

Run:
```bash
git -C ~/.lore/.plugin fetch --quiet 2>/dev/null
LOCAL=$(git -C ~/.lore/.plugin rev-parse HEAD 2>/dev/null)
REMOTE=$(git -C ~/.lore/.plugin rev-parse @{u} 2>/dev/null)
[ "$LOCAL" != "$REMOTE" ] && echo "PLUGIN_UPDATE_AVAILABLE" || echo "PLUGIN_CURRENT"
```

If `PLUGIN_UPDATE_AVAILABLE`: show this notification before the help text:
```
ℹ Lore plugin update available. Run: /lore:update --all
```

---

Display the following help text exactly:

```
LORE — Agentic intelligence graph and delivery engine
════════════════════════════════════════════════════════

  Lore connects project repos to Claude Code, giving you a living
  project memory you can query, brief from, and escalate through.

FRAMEWORK COMMANDS
  /lore:setup <repo-url> <alias>        Connect a project repo
  /lore:status                          Show all connected projects
  /lore:update [alias|--all]            Update framework and/or project plugins
  /lore:uninstall <alias>               Remove a connected project
  /lore:uninstall --all                 Full uninstall (projects + framework)
  /lore                                 Show this help

SETUP EXAMPLES
  /lore:setup github:YourOrg/YourProject myproject
  /lore:setup https://github.com/YourOrg/YourProject.git myproject

ONCE A PROJECT IS CONNECTED
  /<alias>:briefing [exec|vp|leads]     Stakeholder-level briefing
  /<alias>:ask [question]               Query project memory
  /<alias>:escalate [ID or description] Draft an escalation
  /<alias>:overwrite "[wrong]" "[right]" Correct wrong information
  /<alias>:help                         Show commands for that project

INSTALLATION
  Mac/Linux:  bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore-plugin/master/setup.sh)
  Windows:    irm https://raw.githubusercontent.com/Gerald-Illy/lore-plugin/master/setup.ps1 | iex

Framework: ~/.lore/.plugin
════════════════════════════════════════════════════════
```

Do not add commentary. Output only the block above.
