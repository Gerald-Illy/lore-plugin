# Changelog

All notable changes to the Lore plugin.

---

## [1.3.0] — 2026-05-21

### Added
- **Auto-permissions (`settings.json.tpl`):** New template generates `~/.lore/<alias>/.claude/settings.json` at setup time. Auto-allows git operations (pull, push, add, commit, fetch, merge, rev-parse, log), cd, test, and cat on the Lore instance path — users no longer get prompted for every command.
- **Persist step in content-producing skills:** `note`, `todo`, `feedback`, and `recap` templates now include an explicit Step 5 (Persist) with git add/commit/push and user confirmation — same pattern as `overwrite.md.tpl`.

### Changed
- **`setup.md` gains Step 6 (Install permissions):** Generates `.claude/settings.json` into the Lore instance directory using token substitution from `settings.json.tpl`.
- **Setup step numbering:** Register → Step 7, Confirm → Step 8 (was Step 6/7).

---

## [1.2.0] — 2026-05-21

### Added
- **4 new skill commands:** `todo`, `note`, `recap`, `feedback` — drop tasks, save observations, summarize sessions, and report quality issues directly from any project.
- **`/lore:sync [alias|--all]` command:** Fetch, merge, and push project repos in one step. Syncs all projects by default, or a specific one by alias. Also pulls the framework. Resets session markers after sync.
- **Shared preamble (`_base.md.tpl`):** Steps 1–2.5 extracted into a single reusable partial. Skill templates now only contain their unique Steps 3–5/6. Eliminates ~45 lines of duplicated boilerplate per template.

### Changed
- **Session-aware update check (Step 1.5):** Plugin update check now runs only once per session (uses `/tmp/.lore-session-<alias>` marker). After 4h without sync, shows a staleness hint suggesting `/lore:sync <alias>`. No more git fetch on every single command invocation.
- **Template architecture refactored (DRY):** Generation script in `setup.md` now concatenates `_base.md.tpl` + skill-specific template at build time. Self-contained templates (like `help.md.tpl`) with their own `## Step 1` are used as-is. Output remains one fully self-contained file per command — no runtime dependency on the framework.
- **`/lore` renamed to `/lore:help`:** The bare `/lore` command was confusing since it just showed help. Now consistently uses the `:help` suffix like project commands (`/<alias>:help`).
- **`help.md.tpl` expanded:** PLUGIN COMMANDS section now lists all 9 project commands (was 5).
- **`setup.md` Step 7 updated:** Confirmation block shows all generated commands.
- **`status.md` updated:** Commands available section lists all 9 project commands.

### Fixed
- Generation script now skips `_`-prefixed partials (prevents `_base.md` from being generated as a standalone command).

---

## [1.1.0] — 2026-05-13

### Added
- **Plugin update check (Step 1.5):** All 5 command templates (briefing, ask, escalate, overwrite, help) now check if the Lore framework has pending updates after syncing the project repo. Shows a one-line notification (`ℹ Lore plugin update available. Run: /lore:update --all`) without blocking execution.
- **Framework command update check:** `/lore`, `/lore:status`, and `/lore:setup` also check for pending updates and notify. Skipped for `/lore:update` (already updates) and `/lore:uninstall` (user is removing).
- **Lore instance compatibility:** DTA-Launch-Control CLAUDE.md now includes the same update check — works even with old templates installed locally (solves the chicken-and-egg problem).

### Changed
- **Template paths updated for Lore structure changes:**
  - `tagging.md` and `ai-inference.md` moved from `.claude/rules/` to `.claude/refs/` (on-demand loading)
  - Removed `agent-learning.md` reference (concept deleted from Lore)
- **CLAUDE.md updated:** Repo structure, compatibility table, dependency map, briefing skill structure (SKILL.md + 3 variant files), never-invent.md description (consistency check moved to refs/).

### Fixed
- Step 2.5 governance paths in all templates now match the current Lore instance structure.

---

## [1.0.0] — 2026-05-07

### Added
- **Initial release** of the Lore plugin for Claude Code.
- **Framework commands:** `/lore`, `/lore:setup`, `/lore:status`, `/lore:update`, `/lore:uninstall`.
- **Command templates:** `briefing.md.tpl`, `ask.md.tpl`, `escalate.md.tpl`, `overwrite.md.tpl`, `help.md.tpl`, `plugin.json.tpl` — with `{ALIAS}`, `{REPO_URL}`, `{REPO_PATH}` token substitution.
- **Setup scripts:** `setup.sh` (Mac/Linux) and `setup.ps1` (Windows) — bootstrap the framework to `~/.lore/.plugin/` and install commands to `~/.claude/commands/lore/`.
- **Project connection:** `/lore:setup <repo-url> <alias>` clones a Lore instance to `~/.lore/<alias>/` and generates project-specific commands.
- **Update mechanism:** `/lore:update [alias|--all]` pulls framework + regenerates project commands from latest templates.
- **Uninstall:** `/lore:uninstall <alias|--all>` removes projects and optionally the framework.
- **6-step command pattern:** Sync → Identity → Context (rules, refs, overrides) → Skill → Execute → Suggest next steps.
- **Learning curve design:** Every command output ends with 1–3 contextual, copy-pasteable follow-up suggestions.
