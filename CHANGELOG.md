# Changelog

All notable changes to the Lore plugin.

---

## [1.1.0] — 2026-05-13

### Added
- **Plugin update check (Step 1.5):** All 5 command templates (briefing, ask, escalate, overwrite, help) now check if the Lore framework has pending updates after syncing the project repo. Shows a one-line notification (`ℹ Lore plugin update available. Run: /lore:update --all`) without blocking execution.
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
