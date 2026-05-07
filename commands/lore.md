# /lore — Lore help
# Powered by Lore — agentic intelligence graph and delivery engine

---

Display the following help text exactly:

```
LORE — Agentic intelligence graph and delivery engine
══════════════════════════════════════════════════════════

  Lore connects project repos to Claude Code, giving you a living
  project memory you can query, brief from, and escalate through.

FRAMEWORK COMMANDS
  /lore:setup <repo-url> <alias>   Connect a project repo
  /lore:status                     Show all connected projects
  /lore:update [alias|--all]       Update framework and/or project plugins
  /lore                            Show this help

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
  Mac/Linux:  bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.sh)
  Windows:    irm https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.ps1 | iex

Framework: ~/.lore
══════════════════════════════════════════════════════════
```

Do not add commentary. Output only the block above.
