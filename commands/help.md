# /lore:help — Lore help
# Powered by Lore — agentic intelligence graph and delivery engine

---

Display the following help text exactly:

```
LORE — Agentic intelligence graph and delivery engine
══════════════════════════════════════════════════════════

  Lore connects project repos to Claude Code, giving you a living
  project memory you can query, brief from, and escalate through.

FRAMEWORK COMMANDS
  /lore:setup <repo-url> <alias>        Connect an existing project repo
  /lore:setup new <alias>               Create new project from template
  /lore:sync [alias|--all]              Fetch, merge, push project repos
  /lore:status                          Show connected projects + update check
  /lore:update [alias|--all]            Update framework and/or project plugins
  /lore:uninstall <alias>               Remove a connected project
  /lore:uninstall --all                 Full uninstall (projects + framework)
  /lore:help                            Show this help

SETUP EXAMPLES
  /lore:setup github:YourOrg/YourProject myproject    (connect existing)
  /lore:setup new myproject                           (create from template)

ONCE A PROJECT IS CONNECTED
  /<alias>:briefing [exec|vp|leads]     Stakeholder-level briefing
  /<alias>:ask [question]               Query project memory
  /<alias>:escalate [ID or description] Draft an escalation
  /<alias>:overwrite "[wrong]" "[right]" Correct wrong information
  /<alias>:jot [text]                   Capture anything: notes, todos, feedback, recaps
  /<alias>:reasoning [question]         Deep multi-file reasoning for complex queries
  /<alias>:publish [mode] [artifact]    Publish artifact to external platform
  /<alias>:help                         Show commands for that project

INSTALLATION
  Mac/Linux:  bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore-plugin/master/setup.sh)
  Windows:    irm https://raw.githubusercontent.com/Gerald-Illy/lore-plugin/master/setup.ps1 | iex

Framework: ~/.lore/.plugin
══════════════════════════════════════════════════════════
```

Do not add commentary. Output only the block above.
