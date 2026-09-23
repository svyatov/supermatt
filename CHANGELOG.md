# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `code-review`: no longer claims the `claude` peer runs on the default model; `--safe-mode` keeps the user's model selection.
- `ideate`: frame agents get their assigned frames (the fourth takes three), and the Scope question goes through the harness's multiple-choice tool when it has one.
- `wizard`: GitHub variables are a named destination, and the static trace checks every `set_var` name against a `vars.*` reference.
- `triage`: a quick override to `ready-for-agent` on a PR writes the agent brief that state requires.
- `tdd`: the call-count red flag covers internal collaborators only, so a retry-count test at a system boundary no longer contradicts it.
- `prototype`: a logic demo that checks persistence uses `localStorage`, since it has no server.
- `writing-for-agents`: says hosts shorten or drop descriptions when the skill listing overflows, instead of claiming they always stay loaded.
- `grilling`: a round whose questions all have short options goes through the harness's multiple-choice tool when it has one.

## [0.3.0]

### Added

- `ideate`: generates grounded ideas through six frames, has a fresh subagent try to refute each one, and writes the ranked survivors to `docs/ideation/`, each with a prompt that takes it into `/grill-with-docs` in the form the session was invoked with. Adapted from Every's `ce-ideate`.

### Changed

- `architecture-review`: renamed from `improve-codebase-architecture`, because it reviews the codebase and changes no code; run `/architecture-review` (Codex: `$architecture-review`). It assesses the codebase first and writes no report when it is healthy. It finds hot spots by change count over the last year, skips modules that are shallow by design, and names friction with the `codebase-design` red flags. Cards state the deepened module's responsibility and what stays out, and carry a **Tackle later** prompt. It ends by handing the settled refactor to `/to-spec` or `/implement`, gives Codex forms, declares its git and network needs, and sends the report file to a remote user.
- `ask-supermatt`: renamed from `ask-matt`, to match the project name; run `/ask-supermatt` (Codex: `$ask-supermatt`). It tells plugin users to type `/supermatt:name`, keeps a picked `architecture-review` candidate in that skill, and gives the real reason the prototype detour uses `/handoff`.
- `code-review`: adds an **Adversarial** axis that runs through `codex` from Claude Code and `claude` from Codex (adapted from Every's `ce-code-review`), P0-P3 severities with quoted lines, a verdict, and a refactor check on `refactor:` commits. The diff includes uncommitted changes.
- `codebase-design`: defines information leakage and adds a red flags reference (adapted from Luke Ramsden's `software-design`). It leaves the codebase survey to `architecture-review`, and deletes superseded tests in their own commit.
- `diagnosing-bugs`: asks what the user tried, rules out the environment and uncommitted work, fixes nothing until the causal chain has no gaps, and fixes at the source with no bundled refactor. It escalates after 2-3 dead hypotheses or 3 failed fixes, and a bug-class checklist seeds its hypotheses (adapted from Every's `ce-debug` and Superpowers `systematic-debugging`). It writes the regression test through `tdd`, reviews the fix with `code-review`, and sends design findings to `/architecture-review`.
- `domain-modeling`: each context's ADRs number on their own.
- `grilling`: offers the smallest option first and asks at most four questions a round, only ones that change what gets built.
- `handoff`: reports the handoff file's absolute path.
- `implement`: fetches its issues, references them in commits, passes the spec to `code-review`, and closes each issue once the review is clean. The full suite runs before every commit. Refactors keep behavior: characterization tests through `tdd` in their own `test:` commit, test files untouched in `refactor:` commits, and review fixes that change behavior go test-first.
- `pr`: reads the glossary from the `docs/agents/domain.md` layout.
- `prototype`: asks its logic-or-UI question as a choice, indexes `UI.md`, and keeps the prototype on a `prototype/<name>` branch with a pointer even before an issue exists.
- `research`: writes where its caller asks, and does the work itself when it already runs as a subagent.
- `retro`: drops candidates the code or docs already cover, adds a **Drift** category, tells duplication from no-ops, names where session logs live, and says "context pointer".
- `setup-supermatt-skills`: always writes the triage label vocabulary, and records the template operations for an "Other" tracker. The GitHub template creates missing labels and reads the frontier from the sub-issues endpoint. The local tracker gains Close, a `Category:` line, an inbox, and keeps `wayfinder` decisions in `decisions/`.
- `tdd`: checks that a test goes red for the reason it names, counts a cycle green only on the full suite, ends with a mutation check, and flags change-detector tests (adapted from Superpowers `test-driven-development`). It adds a characterization reference, defines a seam as `codebase-design` does, treats seams in the spec or issue as confirmed, and sends a bug with an unknown cause to `diagnosing-bugs`. `mocking.md` allows in-memory adapters at owned ports.
- `teach`: format files use the same names as `SKILL.md`.
- `to-spec`: checks the draft in a fresh-context sub-agent before it publishes (adapted from Every's `ce-doc-review`), takes a `wayfinder` map or issue reference, and records the agreed test seams.
- `to-tickets`: explores the codebase in a subagent, gives each ticket its seams, and uses the tracker's Blocking operation.
- `triage`: uses one `.out-of-scope/` format and puts the AI disclaimer at the top of its templates.
- `wait-what`: uses `TERMS.md` in a `teach` workspace.
- `wayfinder`: names the smallest version before it charts, has a subagent argue for the smallest answer, and tracks **Added so far**. A map is done when the first working version can be built. Research subagents run in their own worktrees, and their tickets are claimed and resolved.
- `wizard`: lists the GitHub variables it set.
- `writing-for-agents`: scopes "zero context load" to Claude Code, and keeps shared reference files inside the plugin root.

## [0.2.1]

### Changed

- Every skill declares `license: MIT` in its frontmatter, so a skill directory copied on its own keeps its license.
- Instructions to run a user-invoked skill also give the Codex form (`$name`), and `ask-matt` notes it once.
- `resolving-merge-conflicts`, `retro`, `triage` and `teach` hand their heavy reading to a sub-agent.
- `wizard` declares its bash requirement in `compatibility`, and its template no longer assumes a setup done in a browser.

### Fixed

- `implement` commits before it runs `code-review`, so the review sees the new work.
- `setup-supermatt-skills` lists external PRs through `gh api`, because `gh pr list` has no `authorAssociation` field, and it maps the `bug` and `enhancement` category labels too.
- `pr` keeps its credits in flat `metadata` keys, as the spec requires string values.
- `ask-matt` describes `/compact` as continuing the same conversation.
- `improve-codebase-architecture` and `to-questionnaire` examples now follow their own rules.

## [0.2.0]

### Added

- `retro` (user-invoked): review a finished coding session and suggest changes to the agent's environment. Imported from mattpocock/skills.
- `pr` (model-invoked): the shape of a pull request body. Imported from mattpocock/skills, with the `show-me` MIT notice in its `CREDITS.md`.

### Fixed

- `ask-matt` no longer says the `diagnosing-bugs` post-mortem hands off to `improve-codebase-architecture`.
- `domain-modeling`: the `GLOSSARY-MAP.md` example now opens with a `# Glossary Map` heading.

## [0.1.0]

### Added

- Claude Code and Codex marketplaces for the plugin and its 25 engineering and productivity skills.
