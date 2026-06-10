# /{ALIAS}:help — What Lore can do for you
# Powered by Lore — agentic intelligence graph and delivery engine

## Step 1 — Session sync (once per session)

Run:
```bash
MARKER="/tmp/.lore-session-{ALIAS}"
if [ -f "$MARKER" ] && [ $(( $(date +%s) - $(cat "$MARKER") )) -lt 14400 ]; then
  echo "SESSION_OK"
else
  echo "FIRST_RUN"
fi
```

Handle the output:

- **`FIRST_RUN`** — First command this session (or >4h since last sync). Do all of the following:
  1. Pull the project repo (if a remote is configured):
     ```bash
     if [ ! -d "$HOME/.lore/{ALIAS}/.git" ]; then
       echo "REPO_MISSING"
     elif git -C {REPO_PATH} remote get-url origin >/dev/null 2>&1; then
       git -C {REPO_PATH} pull --quiet 2>/dev/null || echo "PULL_SKIPPED"
     else
       echo "LOCAL_ONLY"
     fi
     ```
     - If `REPO_MISSING`: tell the user "The Lore repo for `{ALIAS}` is not set up. Reconnect with: `/lore:setup {ALIAS}`" — **Stop here.**
     - If `PULL_SKIPPED`: continue silently.
     - If `LOCAL_ONLY`: continue silently.
  2. Check for plugin updates:
     ```bash
     INSTALLED=$(grep -o '"version": "[^"]*"' ~/.claude/commands/{ALIAS}/plugin.json 2>/dev/null | grep -o '[0-9][0-9.]*')
     AVAILABLE=$(grep -o '"version": "[^"]*"' ~/.lore/.plugin/.claude-plugin/plugin.json 2>/dev/null | grep -o '[0-9][0-9.]*')
     [ -n "$AVAILABLE" ] && [ "$INSTALLED" != "$AVAILABLE" ] && echo "COMMANDS_OUTDATED:$INSTALLED:$AVAILABLE"
     ```
     If `COMMANDS_OUTDATED:<old>:<new>` → show once: `⚠ Plugin commands outdated (v<old> → v<new>). Run: /lore:update {ALIAS}`
  3. Write the session marker:
     ```bash
     date +%s > /tmp/.lore-session-{ALIAS}
     ```

- **`SESSION_OK`** — Proceed silently. No pull, no checks.

**Continue with Step 2 in all cases** (unless stopped by REPO_MISSING).

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
  /{ALIAS}:jot [text]                 Capture anything: notes, todos, feedback, recaps
  /{ALIAS}:reasoning [question]       Deep multi-file reasoning for complex queries
  /{ALIAS}:publish [mode] [artifact]  Publish artifact to external platform
  /{ALIAS}:pull [scope]               Pull fresh data from sources into Lore
  /{ALIAS}:setup [action]             Configure sources and project settings
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
  │                                                             │
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
