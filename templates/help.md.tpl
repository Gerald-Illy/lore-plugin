# /{ALIAS}:help — What Lore can do for you
# Powered by Lore — agentic intelligence graph and delivery engine

## Step 1 — Sync the repo

Run:
```bash
git -C {REPO_PATH} pull --quiet 2>/dev/null || echo "REPO_MISSING"
```

If the output contains `REPO_MISSING`:
- Tell the user: "The Lore repo for `{ALIAS}` is not set up. Reconnect with: `/lore:setup {REPO_URL} {ALIAS}`"
- **Stop here. Do not continue.**

## Step 2 — Show the help

Read `{REPO_PATH}/CLAUDE.md` to understand the full command set available in this Lore instance.

Then output the following — substituting `{ALIAS}` with the actual alias and filling in the full command set from CLAUDE.md:

---

```
Lore — {ALIAS}
Agentic intelligence graph and delivery engine
Connected: {REPO_URL}

═══════════════════════════════════════════════════════════════

PLUGIN COMMANDS (available from any project)

  /{ALIAS}:briefing [exec|vp|leads]   Stakeholder briefing from current Lore state
  /{ALIAS}:ask [question]             Query Lore — intelligence graph → logs → sources
  /{ALIAS}:escalate [ID or desc]      Draft escalation to responsible owner
  /{ALIAS}:overwrite "[x]" "[y]"      Correct wrong information — override + push
  /{ALIAS}:help                       This help page

═══════════════════════════════════════════════════════════════

FULL COMMAND SET (available when working inside ~/.lore/{ALIAS} directly)

[Read from {REPO_PATH}/CLAUDE.md — Commands section — and reproduce here,
organized by Production / Experimental / Roadmap as defined there]

═══════════════════════════════════════════════════════════════

DATA SOURCES

[Read from {REPO_PATH}/CLAUDE.md or SOURCES.md if it exists — list the connected sources]

═══════════════════════════════════════════════════════════════

WHAT LORE IS

  Lore is a living project memory — not an archive, not a dashboard.
  It connects distributed sources into a single queryable intelligence
  graph, surfaces risks before they become blockers, tracks decisions
  with full context, and drives delivery actions.

  The AI acts as Co-Delivery-Lead: transparent, direct, never invents.
  If data is missing — it says so. If something is at risk — it says so.

═══════════════════════════════════════════════════════════════

PREREQUISITES — Optional, but unlocks full power

  Without these tools, Lore works from local intelligence only.
  With them, it can reach into live sources for fresh data.

  ┌─────────────────────────────────────────────────────────────┐
  │ 1. gh CLI (GitHub)                                          │
  │    Install:                                                 │
  │      Windows:  winget install GitHub.cli                    │
  │      macOS:    brew install gh                              │
  │      Linux:    sudo apt install gh                          │
  │    Then:       gh auth login                                │
  └─────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────┐
  │ 2. acli-pii (Atlassian CLI for Jira/Confluence)             │
  │    Install:  npm install -g @nicblu/acli-pii                │
  │    Config:   ~/.acli-pii/config.json                        │
  │      {                                                      │
  │        "baseUrl": "https://your-org.atlassian.net",         │
  │        "email": "you@yourcompany.com",                      │
  │        "apiToken": "<your-atlassian-api-token>"             │
  │      }                                                      │
  └─────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────┐
  │ 3. junoctl (Backstage / internal developer portal)          │
  │    What for: Query software catalog, team composition,      │
  │              component ownership, TechDocs                  │
  │    Install:  follow your organization's setup guide         │
  │    Verify:   junoctl --version                              │
  └─────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────┐
  │ 4. git (required)                                           │
  │    Verify:  git --version                                   │
  └─────────────────────────────────────────────────────────────┘

  Check what you have:
    gh --version && echo "✅ gh" || echo "❌ gh missing"
    acli-pii --version && echo "✅ acli-pii" || echo "❌ acli-pii missing"
    junoctl --version && echo "✅ junoctl" || echo "❌ junoctl missing"
    git --version && echo "✅ git" || echo "❌ git missing"

═══════════════════════════════════════════════════════════════

  Lore framework:  https://github.com/Gerald-Illy/lore
  This instance:   {REPO_URL}

  Connect a new project:
    /lore:setup <repo-url> <alias>

  Reconnect this project:
    /lore:setup {REPO_URL} {ALIAS}
```
