# Lore plugin for Claude Code

Connect any project repo to Claude Code and query it with a project-specific command prefix.

---

## Install

**Mac/Linux:**
```bash
bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.ps1 | iex
```

This clones the Lore plugin to `~/.lore/.plugin/` and installs the `/lore:*` commands in Claude Code.

---

## Connect a project

In any Claude Code session:
```
/lore:setup github:YourOrg/YourProject myproject
```

This clones the project repo to `~/.lore/myproject/` and installs `/myproject:*` commands.

---

## Use it

```
/myproject:briefing leads       → Stakeholder briefing
/myproject:ask "what's blocked" → Query the project memory
/myproject:escalate ISSUE-123   → Draft an escalation
/myproject:overwrite "x" "y"    → Correct wrong information
/myproject:help                 → Show all commands for this project
```

---

## Plugin commands

| Command | What it does |
|---------|-------------|
| `/lore` | Show help |
| `/lore:setup <repo-url> <alias>` | Connect a project repo |
| `/lore:status` | Show all connected projects |
| `/lore:update [alias\|--all]` | Pull latest plugin + regenerate project commands |
| `/lore:uninstall <alias>` | Remove a connected project |
| `/lore:uninstall --all` | Full uninstall (all projects + plugin) |

---

## How it works

```
~/.lore/
  .plugin/              ← Lore plugin (this repo, cloned by setup)
    commands/           ← /lore:* command sources
    templates/          ← Project command templates
  config.json           ← Registry of connected projects
  myproject/            ← Your project repo (cloned by /lore:setup)

~/.claude/commands/
  lore/                 ← Installed /lore:* commands
  myproject/            ← Installed /myproject:* commands
```

`/lore:setup` reads the templates from `~/.lore/.plugin/templates/`, fills in your alias and repo URL, and writes the generated command files to `~/.claude/commands/myproject/`. The plugin itself is never needed again at runtime — each generated command is self-contained.

---

## Multiple projects

```
/lore:setup github:YourOrg/ProjectA alpha
/lore:setup github:YourOrg/ProjectB beta
```

Each gets its own alias and command prefix. Run `/lore:status` to see all connected projects.

---

## What makes a repo compatible?

At minimum, a connected repo needs:
- `CLAUDE.md` — defines the project identity and Claude's role
- `.claude/skills/` — skill definitions (at least `briefing`, `ask`, `escalate`)

Without these, the plugin installs but skill commands will tell you what's missing.

---

## Prerequisites

| Tool | Purpose | Required? |
|------|---------|-----------|
| `git` | Clone and sync repos | Yes |
| `gh` | GitHub access for private repos | Only if repo is private |

---

## Uninstall

Remove one project:
```
/lore:uninstall myproject
```

Remove everything (all projects + the plugin):
```
/lore:uninstall --all
```

---

## License

MIT
