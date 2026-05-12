# CLAUDE.md — Lore Plugin Framework

This repo is the **generic Lore plugin for Claude Code**.
It is not a project instance. It is the framework that connects project instances.

---

## What this repo does

When installed (`setup.sh` / `setup.ps1`), it:
1. Clones itself to `~/.lore/.plugin/`
2. Copies the `/lore:*` commands to `~/.claude/commands/lore/`

When a user runs `/lore:setup github:Org/Repo alias`, it:
1. Self-bootstraps: clones this repo to `~/.lore/.plugin/` if not already present
2. Clones the target project repo to `~/.lore/<alias>/`
3. Reads template files from `~/.lore/.plugin/templates/`
4. Substitutes `{ALIAS}`, `{REPO_URL}`, `{REPO_PATH}` throughout
5. Writes generated commands directly to `~/.claude/commands/<alias>/`
6. Registers the project in `~/.lore/config.json`

---

## Directory structure

```
.claude-plugin/
  plugin.json           ← Plugin manifest. Prefix: "lore". Author: this repo's URL.

commands/
  lore.md               ← /lore — help
  setup.md              ← /lore:setup <repo-url> <alias>
  status.md             ← /lore:status
  update.md             ← /lore:update [alias|--all]
  uninstall.md          ← /lore:uninstall <alias>|--all

templates/
  briefing.md.tpl       ← Generated commands/briefing.md
  ask.md.tpl            ← Generated commands/ask.md
  escalate.md.tpl       ← Generated commands/escalate.md
  overwrite.md.tpl      ← Generated commands/overwrite.md
  help.md.tpl           ← Generated commands/help.md

setup.sh                ← Bootstrap: clone to ~/.lore/.plugin/ + copy commands (Mac/Linux)
setup.ps1               ← Bootstrap: clone to ~/.lore/.plugin/ + copy commands (Windows)
README.md               ← User-facing documentation
CLAUDE.md               ← This file — development context for Claude
```

### Runtime layout (on the user's machine)

```
~/.lore/
  .plugin/              ← this repo, cloned by setup
    commands/           ← source of /lore:* commands
    templates/          ← source of project plugin templates
  config.json           ← registry of connected projects
  dta/                  ← example project instance
  work/                 ← another project instance

~/.claude/commands/
  lore/                 ← installed /lore:* commands (copied from ~/.lore/.plugin/commands/)
  dta/                  ← installed /dta:* commands (generated from templates)
  work/                 ← installed /work:* commands
```

---

## Template system

Templates use three substitution tokens:

| Token | Replaced with |
|-------|--------------|
| `{ALIAS}` | The project alias (e.g. `myproject`) |
| `{REPO_URL}` | The full repo URL (e.g. `https://github.com/Org/Repo.git`) |
| `{REPO_PATH}` | The local clone path (e.g. `~/.lore/myproject`) — NOT shell-expanded |

Every template is a complete, standalone Claude Code command file after substitution.
Templates must never reference project-specific content — they are fully generic.

---

## Command wrapper pattern

Every generated command file follows this exact 6-step pattern:

```
Step 1 — Sync       git -C {REPO_PATH} pull --quiet || echo "REPO_MISSING"
                    If REPO_MISSING: tell user to run /lore:setup again. Stop.

Step 2 — Identity   Read {REPO_PATH}/CLAUDE.md
                    Claude takes on the role defined there for this session.

Step 2.5 — Context  cd {REPO_PATH}  ← critical: all relative paths resolve here
                    Read rules: never-invent, privacy (from rules/)
                    Read refs: tagging, ai-inference (from refs/)
                    Read OVERRIDES.md
                    Skip any file that does not exist.

Step 3 — Skill      Check {REPO_PATH}/.claude/skills/<name>/SKILL.md exists.
                    If missing: tell user, stop.
                    If exists: read it completely.

Step 4 — Execute    Run the skill exactly as defined. Pass $ARGUMENTS through.
                    If a CLI tool is missing: answer from local Lore only,
                    then note what's missing with the install command.

Step 5 — Next steps Suggest 1–3 concrete, copy-pasteable follow-up commands.
                    Tailor to what surfaced. Never suggest more than 3.
```

Step 2.5 (`cd {REPO_PATH}`) is non-negotiable. Without it, relative paths in SKILL.md
resolve against the user's current project — not the Lore repo. This breaks everything.

---

## What Lore-compatible projects must have

| Path | Required | Purpose |
|------|----------|--------|
| `CLAUDE.md` | Yes | Defines Claude's role, rules, and command set for this project |
| `.claude/skills/<name>/SKILL.md` | Yes (per command) | Actual skill logic |
| `.claude/rules/never-invent.md` | Recommended | Core integrity rule + priority hierarchy |
| `.claude/rules/privacy.md` | Recommended | Privacy boundaries |
| `.claude/refs/tagging.md` | Recommended | Tag system (audience + content tags) |
| `.claude/refs/ai-inference.md` | Recommended | AI inference labeling |
| `OVERRIDES.md` | Optional | Human corrections — always win over source data |

If a required file is missing, the command tells the user rather than failing silently.

---

## How to add a new command

1. Add `<name>.md.tpl` to `templates/` following the 6-step pattern above (for project commands)
   — or add `<name>.md` directly to `commands/` (for framework commands like `uninstall`)
2. Add the file to the mapping table in `commands/setup.md` (Step 5) — project commands only
3. Add the command to the confirm block in `commands/setup.md` (Step 7) — project commands only
4. Add the command to the display in `templates/help.md.tpl` — project commands only
5. Add the command to `commands/lore.md` (Framework commands section)
6. Add the command to `commands/status.md` (Commands available section)

The new command will be generated for all future `/lore:setup` calls.
Existing connected projects need to be reconnected: `/lore:setup <repo-url> <alias>`

---

## How to update the framework

After pushing changes to this repo, users run `setup.sh` again to pull the latest.
This updates `~/.lore/` (the framework), not the project repos inside it.

To regenerate a project plugin after a template change:
```
/lore:setup <repo-url> <alias>
```
This is idempotent — it pulls the repo and regenerates the plugin.

---

## Design principles

1. **Fully generic.** No project names, company names, or specific tools in framework files.
   Examples in command files use `YourOrg/YourProject` and `myproject`.

2. **Templates are self-contained.** After substitution, a generated command file must work
   with no dependency on the framework directory. The framework only runs once (at setup).

3. **Fail visibly, not silently.** Every command checks prerequisites (framework present,
   repo cloned, skill exists) and tells the user exactly what's missing and how to fix it.

4. **No project logic in the framework.** The framework's only job is:
   clone → generate → install → register.
   All intelligence, rules, and skill logic lives in the project repo.

5. **The alias is the contract.** Once a user connects a project as `myproject`, all 5
   commands use that prefix. Changing the alias means reconnecting with a new alias.

6. **Reserved alias names.** Aliases must not conflict with framework subdirectories:
   `templates`, `commands`, `config.json`. Document this in README.

---

## config.json structure

```json
{
  "projects": {
    "<alias>": {
      "repo": "<full-repo-url>",
      "path": "~/.lore/<alias>",
      "installed": "YYYY-MM-DD"
    }
  }
}
```

Written by `/lore:setup`, read by `/lore:status`. Not used by generated project commands.

---

## Session end

If you changed any file in this repo during a session:
- Note what changed and why — this CLAUDE.md is the development memory.
- Update README.md if the user-facing behavior changed.
- If template files changed: note that existing connected projects need `/lore:setup` again.

---

## Lore Instance Design

This section describes what a Lore-compatible project repo looks like from the inside.
Plugin developers need this to understand what the generated commands are actually connecting to.

### Core principle: project-level signal only

Lore captures project intelligence — not everything that happens. Sources contain a mix
of logistics, personal reflection, and real delivery signal. Only the last category belongs in Lore.

**Include:** decisions with project impact, risks, stakeholder changes, architecture signals,
scope shifts, milestone changes or threats.

**Never include:** meeting scheduling, tool setup, personal 1:1 content, internal coordination
("synced with X"), routine status with no change from last known state.

**The signal test:** If the delivery lead read this in a briefing in 6 months, would it tell them
something they need to know? If no — skip it.

### Core principle: pointers, not content

```
Sources  → where the content lives (Jira, Confluence, GitHub, SharePoint…)
Lore     → what happened, why, and where to find it
```

A Jira ticket is not copied into the log. A Confluence page is not copied into the log.
Only: what changed, why it's relevant, where to find it.

Every log entry has three layers:
1. **Narrative** — what happened, why, in what context. Human-readable, no schema.
2. **Structured tags** — `[audience][type] What – Owner – Date – →ctx/→concept/Link`
3. **Pointers** — `→ctx:[ID]` (full context chunk), `→concept:slug` (knowledge node), `[Link]`

### Repository structure of a Lore instance

```
project-root/
├── CLAUDE.md                    ← Entry point: role, startup sequence, skill table
├── SOURCES.md                   ← What sources exist and where (human-maintained)
├── OVERRIDES.md                 ← Human corrections — always win over source data
├── CHANGELOG.md                 ← Auto-logged after every session with file changes
├── .claude/
│   ├── lore-design.md           ← Core design principles (signal, pointer, philosophy, tags)
│   ├── agents/                  ← Pull agents per source (confluence, jira, journal, sharepoint…)
│   ├── rules/                   ← Always auto-loaded (every session)
│   │   ├── never-invent.md      ← Core integrity rule + priority hierarchy
│   │   ├── auto-log.md          ← CHANGELOG entry required after every session
│   │   └── privacy.md           ← Public / Confidential / Private section convention
│   ├── refs/                    ← Loaded on demand by skills/agents that need them
│   │   ├── tagging.md           ← Audience + content tag system
│   │   ├── condensing.md        ← Log lifecycle (daily → weekly → monthly → yearly)
│   │   ├── log-writing.md       ← How daily logs are written
│   │   ├── log-links.md         ← Clickable source references in all logs
│   │   ├── ai-inference.md      ← AI-inferred hypotheses: labeling, lifecycle, quality bar
│   │   ├── extraction-quality.md ← Pull extraction: inclusion checklists, thoroughness
│   │   ├── consistency-check.md ← Consistency check spec (what gets checked, resolution)
│   │   └── lore-reference.md    ← Repo structure, workflows, dependency map, setup checklist
│   ├── skills/
│   │   ├── briefing/SKILL.md    ← /briefing shared base (routing + rules)
│   │   ├── briefing/exec.md     ← Executive variant template
│   │   ├── briefing/vp.md       ← VP variant template
│   │   ├── briefing/leads.md    ← Delivery lead variant template
│   │   ├── ask/SKILL.md         ← Three-layer search: knowledge → logs → sources
│   │   ├── escalate/SKILL.md    ← Draft escalation to responsible owner
│   │   ├── override/SKILL.md    ← Correct wrong information
│   │   ├── pull/SKILL.md        ← Pull fresh data from sources (orchestrator)
│   │   ├── inconsistencies/SKILL.md
│   │   ├── plan/SKILL.md
│   │   ├── log-changes/SKILL.md
│   │   ├── setup/SKILL.md
│   │   ├── atlassian/SKILL.md   ← Query Jira/Confluence via acli-pii CLI
│   │   ├── juno-catalog/SKILL.md ← Query Backstage catalog via junoctl
│   │   ├── publish-confluence/SKILL.md
│   │   └── retroactive/SKILL.md
│   └── skills-todo/             ← Stubs not yet implemented
├── .lore/
│   ├── config.md                ← Per-source navigation, key pages, priorities
│   ├── pending.md               ← Items not yet read
│   ├── inconsistencies.md       ← Open contradictions, updated after every pull
│   ├── setup-log.md             ← Setup agent session memory
│   ├── backlog.md               ← Missing capabilities and open problems
│   └── manifests/               ← Last-known source state for delta detection
│       ├── jira.json
│       ├── confluence.json
│       ├── sharepoint.json
│       └── github.json
├── log/
│   ├── onboarding/              ← First pull baseline; readonly after creation
│   ├── daily/                   ← YYYY-MM-DD.md; condensed after 14 days
│   ├── weekly/                  ← Condensed after 3 months
│   ├── monthly/                 ← Condensed after 6 months
│   ├── quarterly/               ← Condensed after 6 quarters
│   ├── yearly/                  ← Never deleted, never condensed
│   └── context/                 ← Context chunks for decisions/risks; never deleted
└── knowledge/
    ├── INDEX.md                 ← Navigation table; updated when any file changes
    ├── scope.md                 ← Project purpose, MVP scope, boundaries
    ├── roadmap.md               ← Milestones with dates
    ├── workstreams.md           ← Key epics per workstream
    ├── dependencies.md          ← Cross-workstream dependencies
    ├── decisions-open.md        ← Open decisions not yet made
    ├── architecture.md          ← ADRs (Architecture Decision Records)
    ├── team.md                  ← Roles, stakeholders, ownership
    ├── principles.md            ← Non-negotiable project principles
    └── concepts/                ← Knowledge nodes; created by /consolidate
```

### Information priority (when sources conflict)

At equal timestamps, this hierarchy applies:

1. `OVERRIDES.md` — explicitly decided human corrections
2. `log/context/` — documented decisions with full context
3. `knowledge/` — verified, human-approved knowledge
4. `log/daily/` — freshest operational log
5. External sources (Confluence, Jira, GitHub, SharePoint…)

A conflict with `knowledge/` is always critical — it means either an undocumented decision
was made or someone is working against an established direction.

### Tagging system

**Audience tags** — mandatory on every [decision], [risk], [action], [question]. Default: `[lead]`.

| Tag | For |
|-----|-----|
| `[exec]` | C-Level — strategic decisions only |
| `[vp]` | VP level — full project view |
| `[lead]` | Delivery Lead — operational |
| `[team]` | Internal, technical |

**Content tags**

| Tag | What | Follow-up |
|-----|------|----------|
| `[decision]` | Decision made | Create context chunk in log/context/ |
| `[risk]` | Identified risk | Context chunk + trend tag (`[↑]` `[→]` `[↓]`) |
| `[action]` | Task with owner + date | — |
| `[question]` | Open question | Context chunk if complex |
| `[arch]` | Architecture-relevant | Draft ADR |
| `[concept]` | New concept | Check/create knowledge node |

### Consistency check

Full spec: `.claude/refs/consistency-check.md`

Runs automatically after every `/pull` and every `/briefing`.
Results written to `.lore/inconsistencies.md`. Never auto-resolved — always surfaced to the human.

| Criticality | Meaning |
|-------------|--------|
| 🔴 Knowledge conflict | Contradicts knowledge/ — shown first, always |
| 🟡 Source conflict | Two sources disagree |
| 🟢 Missing data | Owner, deadline, or link missing |

### What Lore never does

- Invent facts not in a source
- Resolve conflicts without a human decision
- Read live sources during briefings (works from local Lore only)
- Modify sources — read only
- Auto-resolve an inconsistency because a source changed
- Skip the consistency check after a pull

### Source links

Every source reference must include a clickable link when the URL can be constructed.
Base URLs come from the project's `SOURCES.md` — never hardcoded in skills or agents.

```
Confluence  [Page Title](https://{instance}/wiki/spaces/{SPACE}/pages/{ID})
Jira        [KEY-123](https://{instance}/browse/{KEY-123})
GitHub      Standard GitHub URLs to commits, files, PRs
```

### Dependency map (when changing a Lore instance)

Full dependency map: `.claude/refs/lore-reference.md`

| Changed file | Must also update |
|---|---|
| New skill in `.claude/skills/` | `CLAUDE.md` skill table, `refs/lore-reference.md`, `CHANGELOG.md` |
| New rule in `.claude/rules/` | `CHANGELOG.md` |
| New agent in `.claude/agents/` | `CLAUDE.md` agents table, `refs/lore-reference.md`, `CHANGELOG.md` |
| `log-writing.md` changed | `skills/pull/SKILL.md` (log format must stay in sync) |
| Tag system changed | `log-writing.md`, `lore-design.md`, `skills/pull/SKILL.md` |
| `knowledge/INDEX.md` | Must reflect all files in `knowledge/` |
| Any file created/modified/deleted | `CHANGELOG.md` — no exceptions |
