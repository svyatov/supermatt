# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `architecture-review` report cards carry a **Tackle later** prompt that takes a candidate into `/grill-with-docs` in a fresh session.
- `architecture-review` assesses the codebase before it writes a report. A finding must cause change amplification, cognitive load, or unknown unknowns. On a healthy codebase, the skill says so and writes no report.
- `architecture-review` cards state the deepened module's responsibility and what stays out of it, and a candidate whose responsibility needs "and" more than once is split or dropped.
- `architecture-review` skips modules that are shallow by design: thin adapters, data classes, and configuration loaders.
- `tdd` has a characterization test reference, to pin the current behavior of untested code before a change.
- `implement` has rules that keep behavior the same during a refactor, or while fixing what `code-review` found.
- `code-review` flags a `refactor:` commit that changes a test file beyond a rename or a move.
- `codebase-design` defines information leakage, back-door leakage included, and the two ways to repair a leak.
- `codebase-design` has a red flags reference that names signs of shallow and leaky modules. `architecture-review` names the friction it finds with these flags. Adapted from Luke Ramsden's `software-design` skill, credited in `CREDITS.md`.

### Changed

- `improve-codebase-architecture` is now `architecture-review`, because it reviews the codebase and changes no code. Run `/architecture-review` (Codex: `$architecture-review`) instead.
- `architecture-review` finds hot spots by change count over the last year, ranked by complexity, and leaves out bot and bulk reformat commits.

### Fixed

- `architecture-review` ends by handing the settled refactor to `/to-spec` or `/implement`, where before the grilling had no exit.
- `ask-matt` no longer sends a picked `architecture-review` candidate to `/grill-with-docs`, which the skill already does inline.
- `code-review` includes uncommitted changes in the diff, so it can review work in progress as its description says.
- `architecture-review` gives the Codex form of the skills it hands off to, allows a `Healthy` verdict in the report header, and calls the card field **Wins** in both files.
- `ask-matt` gives the right reason the prototype detour uses `/handoff`, and lists forking a side task among the mid-phase moves.
- `prototype` asks its logic-or-UI question through a multiple-choice tool where the harness has one, and `UI.md` has a table of contents.

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
