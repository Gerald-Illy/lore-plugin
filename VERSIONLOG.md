# Version Log

All versions of the Lore plugin.

---

## [2.0.0] — 2026-06-09

### BREAKING CHANGE
- **Template setup now requires explicit `new` keyword:** `/lore:setup <alias>` alone is no longer valid. Use `/lore:setup new <alias>` to create from template. This makes the intent explicit and prevents accidental template creation when a user forgets the repo URL.
- **Updated all documentation:** `commands/help.md`, `commands/setup.md`, and `commands/status.md` now reflect the new syntax.

---

## [1.5.0] — 2026-06-09

### Added
- **Template mode for `/lore:setup`:** Running `/lore:setup <alias>` without a repo URL now creates a fresh local Lore project from the [lore-template](https://github.com/Gerald-Illy/lore-template.git). No GitHub repo needed — the project lives under `~/.lore/<alias>` with a local-only git repo.
- **Automatic `{PROJECT_NAME}` replacement:** Template placeholders are replaced with the alias name during setup — no manual find/replace needed.
- **Post-creation status report:** After template setup, a structured report shows project structure, remaining placeholders, and guided next steps (configure SOURCES.md → first pull → first briefing).
- **Built-in setup check:** If the template includes a `/lore check` skill, it runs automatically after creation to validate the project structure.
- **`source` field in `config.json`:** Template-created projects are marked with `"source": "template"` to distinguish them from connected repos.
- **`reasoning.md.tpl`:** New command template for deep multi-agent retrieval with semantic reasoning. Built-in minimal skill provides cross-file synthesis when no project SKILL.md exists.
- **`publish.md.tpl`:** New command template for publishing artifacts to external platforms. Built-in minimal skill generates shareable markdown artifacts when no project SKILL.md exists.
- **Built-in minimal skills for all templates:** Every template now includes a fallback skill that works when connecting a non-Lore repo (no SKILL.md required). Templates no longer stop with "skill not available" — they provide basic functionality out of the box.

### Changed
- **Command count increased from 6 to 8:** Project commands are now: briefing, ask, escalate, overwrite, jot, reasoning, publish, help.
- **Preamble pull logic robustified:** Step 1 now checks if the repo directory exists and if a remote is configured before attempting `git pull`. Local-only projects (no remote) skip the pull silently instead of showing a false "REPO_MISSING" error.
- **Setup confirmation split by mode:** Template-created projects get a full status report with next steps instead of a simple confirmation message.
- **`help.md.tpl` updated:** PLUGIN COMMANDS section now lists all 8 project commands (was 6). Pull logic aligned with new preamble.
- **All existing templates updated:** Step 3 logic changed from "stop if no SKILL.md" to "use built-in minimal skill if no SKILL.md".

---

## [1.4.1] — 2026-05-21

### Fixed
- **Session marker false positive:** Markers >4h old (from previous sessions on Windows) no longer trigger a stale warning. Now treated as new session — pulls fresh and writes new marker.

### Removed
- **`_base.md.tpl`:** Deleted along with build-time concatenation logic in `regenerate.sh`. Runtime preamble makes it unnecessary.

---

## [1.4.0] — 2026-05-21

### Added
- **`/jot` command:** Unified capture skill replaces 4 separate commands (todo, note, recap, feedback). Detects type from first word or context. Single entry point for all session-time contributions.
- **Runtime `_preamble.md`:** New `_preamble.md.tpl` generates `~/.claude/commands/{ALIAS}/_preamble.md` at setup time. Contains Steps 0–2.5 (help check, session sync, identity, context entry) + available commands list. Skills read this at runtime instead of embedding the boilerplate.
- **Persist step in `/jot`:** Step 5 offers to git add/commit/push when files were created.

### Changed
- **Session sync merged:** Step 1 + 1.5 consolidated into single "Step 1 — Session sync". Git pull only runs on first invocation per session (marker-based). Subsequent commands skip the pull entirely. After 4h shows staleness hint.
- **Skill templates slimmed:** All skill templates (briefing, ask, escalate, overwrite, jot) now contain only Steps 3–6 + Help. They reference the runtime preamble with "Read `_preamble.md` and execute Steps 0–2.5 before continuing."
- **`regenerate.sh` simplified:** Removed `_base.md.tpl` concatenation logic. Now just runs each template through `sed` directly.
- **Command count reduced from 9 to 6:** Project commands are now briefing, ask, escalate, overwrite, jot, help.
- **`CHANGELOG.md` → `VERSIONLOG.md`:** Renamed for clarity.

### Removed
- **`_base.md.tpl`** — no longer needed (runtime preamble replaces build-time concatenation).
- **`todo.md.tpl`**, **`note.md.tpl`**, **`recap.md.tpl`**, **`feedback.md.tpl`** — replaced by `jot.md.tpl`.

---

## [1.3.1] — 2026-05-21

### Added
- **`scripts/regenerate.sh`:** Centralized project plugin generation script. Both `setup.md` and `update.md` call this script instead of embedding inline bash loops. Future changes to generation logic only require updating this one file.
- **Self-updating `/lore:update`:** Step 2 now explicitly pulls the framework and re-installs framework commands BEFORE running the regeneration script. Since the script lives in the freshly pulled framework, it's always the latest version — no more chicken-and-egg problems.

### Changed
- **Templates fully self-contained:** All 8 skill templates now contain the complete base preamble (Steps 0–2.5 + Available commands) inline. `_base.md.tpl` is empty (placeholder for future re-extraction once all users are on this version).
- **Generation scripts simplified:** `setup.md` and `update.md` both delegate to `scripts/regenerate.sh` instead of inline loops.
- **`setup.md` generates `plugin.json`:** Step 5 now also runs `plugin.json.tpl` through token substitution via the regeneration script.

### Fixed
- **Skill description in Claude Code:** Templates now start with the correct `# /{ALIAS}:command — Description` line as the first content, so Claude Code shows meaningful skill names instead of "Powered by Lore".
- **CHANGELOG accuracy:** 1.3.0 and 1.2.0 entries corrected to reflect actual release scope.

---

## [1.3.0] — 2026-05-21

### Added
- **Auto-permissions (`settings.json.tpl`):** New template generates `~/.lore/<alias>/.claude/settings.json` at setup time. Auto-allows git operations on the Lore instance path — users no longer get prompted for every command.
- **Persist step in content-producing skills:** `note`, `todo`, `feedback`, and `recap` templates now include a Step 5 (Persist) with git add/commit/push and user confirmation.
- **`--help` / `-h` support on every skill command:** Step 0 (Help check) in `_base.md.tpl` intercepts `--help` or `-h` and displays the command's built-in Help section. All 8 skill templates now have a `## Help` block with usage, arguments, and examples.
- **Session-aware update check (Step 1.5):** Version comparison (installed `plugin.json` vs available `plugin.json`) runs once per session using `/tmp/.lore-session-<alias>` marker. After 4h shows a staleness hint suggesting `/lore:sync`.
- **Available commands allowlist:** `_base.md.tpl` includes an explicit list of installed plugin commands. Claude is instructed to never suggest commands outside this list — repo-only commands are framed differently.
- **`/lore:sync [alias|--all]` command:** Fetch, merge (`--ff-only`), and push project repos in one step. Also pulls the framework. Resets session markers after sync.
- **`plugin.json` generation in setup:** `setup.md` Step 5 now also generates `plugin.json` from `plugin.json.tpl` for version tracking.

### Changed
- **Merged `/lore` and `/lore:help` into one command:** Deleted `commands/lore.md`. `/lore:help` is now the single help entry point.
- **Version comparison replaces git-hash check:** Step 1.5 compares version strings from `plugin.json` files instead of `git rev-parse`. This correctly detects when the framework is pulled but commands haven't been regenerated.
- **`/lore:update` cleans before regenerating:** `rm -rf` target directory before `mkdir` + generate — removes ghost commands from deleted templates.
- **`setup.md` gains Step 6 (Install permissions):** Generates `.claude/settings.json` into the Lore instance directory using token substitution from `settings.json.tpl`.
- **Setup step numbering:** Register → Step 7, Confirm → Step 8 (was Step 6/7).
- **`status.md` shows installed vs available version:** Reads installed version from `~/.claude/commands/<alias>/plugin.json` and available from `~/.lore/.plugin/.claude-plugin/plugin.json`.

### Removed
- `commands/lore.md` — superseded by `commands/help.md`

---

## [1.2.0] — 2026-05-21

### Added
- **4 new skill commands:** `todo`, `note`, `recap`, `feedback` — drop tasks, save observations, summarize sessions, and report quality issues directly from any project.
- **Shared preamble (`_base.md.tpl`):** Steps 1–2.5 extracted into a single reusable partial. Skill templates now only contain their unique Steps 3–5/6. Eliminates ~45 lines of duplicated boilerplate per template.

### Changed
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
