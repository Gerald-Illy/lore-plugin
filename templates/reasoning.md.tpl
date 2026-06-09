# /{ALIAS}:reasoning — Deep reasoning over project intelligence

Arguments: `$ARGUMENTS` (complex question requiring cross-file synthesis)

---

Read `~/.claude/commands/{ALIAS}/_preamble.md` and execute Steps 0–2.5 before continuing.

---

## Step 3 — Load the skill

Check if `{REPO_PATH}/.claude/skills/reasoning/SKILL.md` exists.

If it does **not** exist: use the **built-in minimal skill** below.
If it exists: read it completely and use it instead.

## Step 4 — Execute

Execute the reasoning skill exactly as defined in SKILL.md (or the built-in below).
The question to answer is: `$ARGUMENTS`

If no argument was provided: ask the user what they want to reason about.

**If a CLI tool is missing:** When the skill would use `acli-pii` or `gh` for live data but the tool is not available:
1. Answer from local project files (knowledge/, logs/, docs/, README, CLAUDE.md)
2. Then note what couldn't be reached:
   ```
   Info: Answer from local files only. For live data from [Jira/Confluence/GitHub]:
   [specific install command]
   Then retry: /{ALIAS}:reasoning "$ARGUMENTS"
   ```

## Step 5 — Suggest next steps

After answering, suggest 1–3 follow-up actions based on what surfaced.

- Answer reveals risk → "Escalate? `/{ALIAS}:escalate [risk]`"
- Answer is exec-relevant → "Brief leadership: `/{ALIAS}:briefing exec`"
- Contradictions found → "Correct: `/{ALIAS}:overwrite "[wrong]" "[correct]"`"
- Answer incomplete → "Dig into one aspect: `/{ALIAS}:reasoning "[follow-up]"`"

Max 3. Pick what's most actionable.

---

## Built-in Minimal Skill

Use this when `{REPO_PATH}/.claude/skills/reasoning/SKILL.md` does not exist.

### Purpose

Deep multi-file reasoning for questions that need cross-cutting synthesis.
Unlike `/ask` (quick lookup), `/reasoning` reads broadly, follows connections,
and builds a complete picture before answering.

### Flow

1. **Understand the question** — restate it. Identify what dimensions it touches.
2. **Broad retrieval** — read ALL of:
   - `{REPO_PATH}/CLAUDE.md`
   - `{REPO_PATH}/OVERRIDES.md` (if exists)
   - All files in `{REPO_PATH}/knowledge/` (if exists)
   - Recent entries in `{REPO_PATH}/log/daily/` (last 7 days, if exists)
   - `{REPO_PATH}/README.md` (if exists)
3. **Follow connections** — for each significant connection found, read the related files.
4. **Consistency check** — do sources agree? Surface contradictions.
5. **Synthesize** — build a complete answer. Mark inferences explicitly.

### Output Format

```
## [Answer title]

[Comprehensive answer with attributed claims]

### Sources Used
| Source | File | Relevance |
|--------|------|-----------|
| ... | ... | ... |

### Confidence: [1-5]
[Why this confidence level — what's missing?]
```

### Rules (built-in)
- Never invent facts not in available files
- Never resolve contradictions — surface both sides
- Mark inferences with [inferred]
- OVERRIDES.md has priority over all other files

## Help

```
/{ALIAS}:reasoning — Deep reasoning over project intelligence

Usage:  /{ALIAS}:reasoning [question]

Arguments:
  Any complex question requiring cross-file synthesis.

When to use (instead of /ask):
  - Question needs information from multiple files
  - Question requires understanding HOW things connect
  - Answer has high impact (decision basis, escalation)
  - Previous /ask answer was insufficient

Examples:
  /{ALIAS}:reasoning "What's actually blocking launch readiness?"
  /{ALIAS}:reasoning "How do the dependencies affect all workstreams?"
  /{ALIAS}:reasoning "Is the team allocation consistent with roadmap priorities?"
```
