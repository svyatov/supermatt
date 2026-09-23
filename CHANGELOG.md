# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `ideate` skill: generate grounded ideas through six frames, have a fresh subagent try to refute each one, and write the ranked survivors to `docs/ideation/`, each with a prompt that takes it into `/grill-with-docs`. Adapted from Every's `ce-ideate`.
- `retro` drops a candidate when the code, tests, or existing docs already carry the lesson, amends an existing rule or check instead of adding a duplicate, and says so when nothing qualifies.
- `retro` has a **Drift** category: a steering file the session read that points at a path, command, or rule the code no longer supports, or two steering files that contradict each other.
- `retro` removes an instruction as a no-op only when it can quote another file that already states the same rule.
- `retro` names where Claude Code and Codex keep session logs.
- `to-spec` checks the draft spec in a fresh-context sub-agent before it publishes: contradictions, decisions the codebase cannot support, and user stories that nothing covers. The coherence and feasibility lenses come from Every's `ce-doc-review`.
- `architecture-review` report cards carry a **Tackle later** prompt that takes a candidate into `/grill-with-docs` in a fresh session.
- `architecture-review` assesses the codebase before it writes a report. A finding must cause change amplification, cognitive load, or unknown unknowns. On a healthy codebase, the skill says so and writes no report.
- `architecture-review` cards state the deepened module's responsibility and what stays out of it, and a candidate whose responsibility needs "and" more than once is split or dropped.
- `architecture-review` skips modules that are shallow by design: thin adapters, data classes, and configuration loaders.
- `tdd` has a characterization test reference, to pin the current behavior of untested code before a change.
- `implement` has rules that keep behavior the same during a refactor, or while fixing what `code-review` found.
- `code-review` flags a `refactor:` commit that changes a test file beyond a rename or a move.
- `code-review` has an **Adversarial** axis that looks for the ways a change fails in production. From Claude Code it runs through `codex`, and from Codex through `claude`, read-only and with MCP servers and plugins off. Without the other CLI, it runs as a normal sub-agent. Adapted from Every's `ce-code-review`, credited in `CREDITS.md`.
- `code-review` findings carry a P0-P3 severity and quote the line they flag, and every axis skips pre-existing code, linter territory, and speculative concerns. The report ends with a verdict: Not ready, Ready with fixes, or Ready.
- `wayfinder` names the smallest version before it charts a map, and stops if building that version would teach more than planning it.
- `wayfinder` has a subagent argue for the smallest answer before a ticket is recorded, prunes tickets and fog each answer makes unneeded, and tracks what the decisions add in a new **Added so far** map section.
- `diagnosing-bugs` asks what the user already tried, rules out the environment and the user's uncommitted work before it forms hypotheses, and audits its assumptions. A prediction must name something not yet looked at.
- `diagnosing-bugs` fixes nothing until it can state the causal chain with no gaps, treats a bug that vanishes under a probe as a timing clue, and escalates after 2-3 dead hypotheses or 3 failed fixes with a table that names the likely cause. A bug-class checklist seeds its hypotheses. Adapted from Every's `ce-debug`, credited in `CREDITS.md`.
- `codebase-design` defines information leakage, back-door leakage included, and the two ways to repair a leak.
- `codebase-design` has a red flags reference that names signs of shallow and leaky modules. `architecture-review` names the friction it finds with these flags. Adapted from Luke Ramsden's `software-design` skill, credited in `CREDITS.md`.

### Changed

- `improve-codebase-architecture` is now `architecture-review`, because it reviews the codebase and changes no code. Run `/architecture-review` (Codex: `$architecture-review`) instead.
- `architecture-review` finds hot spots by change count over the last year, ranked by complexity, and leaves out bot and bulk reformat commits.
- `grilling` offers the smallest option first in every question and recommends it unless a concrete case fails. It asks at most four questions a round, and only questions that change what gets built.
- `tdd` checks that a new test goes red for the reason it names, counts a cycle green only when the full suite passes, and ends with a mutation check. It flags change-detector tests, and `mocking.md` covers asserting on mocks, partial mock data, and test-only methods in production classes. Adapted from obra's Superpowers `test-driven-development`.
- A `wayfinder` map is done when the first working version can be built, and "not needed" closes a ticket as out of scope.

### Fixed

- `architecture-review` ends by handing the settled refactor to `/to-spec` or `/implement`, where before the grilling had no exit.
- `ask-matt` no longer sends a picked `architecture-review` candidate to `/grill-with-docs`, which the skill already does inline.
- `code-review` includes uncommitted changes in the diff, so it can review work in progress as its description says.
- `architecture-review` gives the Codex form of the skills it hands off to, allows a `Healthy` verdict in the report header, and calls the card field **Wins** in both files.
- `ask-matt` gives the right reason the prototype detour uses `/handoff`, and lists forking a side task among the mid-phase moves.
- `prototype` asks its logic-or-UI question through a multiple-choice tool where the harness has one, and `UI.md` has a table of contents.
- `wayfinder` runs each research subagent in its own git worktree, and keeps out-of-scope tickets out of Decisions so far in the map template.
- `triage` uses one `.out-of-scope/` file format in its example brief and its reference.
- `tdd` shows a valid Jest call in its implementation-detail example, and the README no longer says refactoring is part of its loop.
- `implement` calls the Skill tool with `tdd` before it writes characterization tests.
- The `setup-supermatt-skills` tracker templates name the same map sections as `wayfinder`.
- `diagnosing-bugs` reports a missing regression-test seam to the user in its cleanup checklist, where before it flagged the seam for a phase that did not exist.

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
