# Lore

**Agentic intelligence graph and delivery engine.**

Lore connects any project's distributed sources — Jira, Confluence, GitHub, SharePoint, internal portals — into a single queryable memory. It surfaces risks, tracks decisions, prepares briefings, and drives delivery actions.

This repo is the **generic Lore plugin for Claude Code**. It gives you access to any Lore-compatible project repo from any Claude Code session, under a project-specific command prefix.

---

## Quick start

**1. Install the Lore plugin**

Mac/Linux:
```bash
bash <(curl -s https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.sh)
```

Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/Gerald-Illy/lore/master/setup.ps1 | iex
```

This clones Lore to `~/.lore/` and installs the `/lore` plugin in Claude Code.

**2. Connect a project repo**

In Claude Code, run:
```
/lore:setup github:YourOrg/YourProject myproject
```

This clones your project to `~/.lore/myproject/` and installs a `/myproject:*` plugin.

**3. Use it**

```
/myproject:briefing leads       → Stakeholder briefing
/myproject:ask "what's blocked" → Query the project memory
/myproject:escalate ISSUE-123   → Draft an escalation
/myproject:overwrite "x" "y"   → Correct wrong information
/myproject:help                 → Full reference
```

---

## How it works

```
~/.lore/                        ← Lore framework (this repo, cloned by setup)
  templates/                    ← Command file templates for project plugins
  commands/                     ← /lore:setup, /lore:status
  config.json                   ← Registry of connected projects

  myproject/                    ← Your project repo (cloned by /lore:setup)
    CLAUDE.md                   ← Project identity (read by every command)
    .claude/skills/             ← Skill definitions (briefing, ask, escalate…)
    .claude/rules/              ← Governance rules (never-invent, privacy…)
    OVERRIDES.md                ← Human corrections — always win
    .lore/agent-learning.md     ← What Claude got wrong before
    knowledge/                  ← Verified project knowledge
    log/                        ← Daily/weekly/monthly logs
    .lore-plugin/               ← Generated plugin, installed as /myproject:*
```

When you run `/myproject:briefing`, Claude:
1. Pulls the latest from the project repo
2. Reads the project `CLAUDE.md` to take on the correct role
3. Loads governance rules and corrections
4. Reads the `briefing` skill definition from `.claude/skills/briefing/SKILL.md`
5. Executes the skill with full project context

---

## Multiple projects

You can connect as many projects as you want. Each gets its own alias and command prefix:

```
/lore:setup github:YourOrg/ProjectA alpha
/lore:setup github:YourOrg/ProjectB beta
```

Results in `/alpha:briefing`, `/beta:briefing`, etc. — all independent, all from any session.

---

## What makes a repo Lore-compatible?

At minimum:
- `CLAUDE.md` — defines the project identity and Claude's role
- `.claude/skills/` — contains skill definitions (at least `briefing`, `ask`, `escalate`)

Without these, the plugin installs but skills won't execute.

---

## Prerequisites

| Tool | What for | Optional? |
|------|----------|-----------|
| `git` | Required — clones repos | No |
| `gh` | GitHub access (Journal, source repos) | Yes |
| `acli-pii` | Jira / Confluence live data | Yes |
| `junoctl` | Backstage / internal developer portal | Yes |

Without optional tools, Lore works from local knowledge only and notes what's missing.

---

## Lore status

```
/lore:status    → Show all connected projects and last sync time
```

---

## License

MIT
