# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.2] - 2026-09-29

### Changed

- `triage`: when the maintainer delegates ("I am away"), every point that waits for direction takes the recommended option and records it as a decision, follow-up issues included. When verification disproves a statement in the issue body, triage corrects the body, or opens the brief with the correction when an outside reporter wrote it, so a later PR does not repeat the false claim. `AGENT-BRIEF.md` adds Checked claims: a brief line that says nothing needs to change, or that a case cannot happen, names the check that proved it, and each Key interfaces line is read against every decision, so a brief no longer covers only the case that was reproduced.
- `implement`: when a slice's own checks are the lint and the full suite, the commit goes on that same call, so the two checks do not run twice in a row. A review fix that changes behavior now gets its own review of the fix commits after QA, since a fix can carry a new bug that QA cannot reach. Each finished slice is committed as it lands, since the old single commit at the end carried a whole ticket (583 lines) past five atomic-commit reminders. The branch off the default branch is made before the work starts, since a commit on `main` reached the repo's branch hook only after the lint and the full suite had run.
- `code-review`: the peer's `prompt.md` is written with the diff path and the binary path already in it as absolute paths, so the agent no longer writes a placeholder and then edits the file in place with `sed`. When the diff changes what a selector, query, or condition matches and the spec asks for unchanged behavior, a reviewer runs the old and new forms on the same input before calling them equivalent, and reports an equivalence it did not run as `unverified`. A finding's `file:line` is the file's own line, from the `+` side of the hunk header, since reviewers cited `diff.patch` lines past the end of the file.
- `qa`: a driver script waits on text with `tui wait` after each step, since a fixed `sleep` read the screen before startup or a sync had drawn it. For a refactor, the expected result is the base build's screen: both builds run from folders with the same name and the same seeded state, and only a per-run value such as a clock is masked before the captures are diffed. The base build comes from a `git archive` export, since a dependency install in a `git worktree` ran the old commit's `prepare` script and replaced the main checkout's git hooks. `tui.sh keys -l TEXT` types TEXT as literal text, since an agent reached for `-l` twice in one pass and `keys` typed the flag into a path prompt.
- `tdd`: a cycle is green only once the project's lint and typecheck pass too, since a lint first run after the last cycle returned nine findings at once.
- `setup-supermatt-skills`: the GitHub tracker template resolves a bare `#42` with one `gh api` call that reports issue or PR, since the old `gh pr view` first step failed on every issue number.

## [0.8.1] - 2026-09-29

### Fixed

- `qa`: `tui.sh keys` escapes a `;` at the end of a key, which tmux reads as its command separator even after `-l`, so a SQL statement such as `BEGIN IMMEDIATE;` reaches the program whole. `TERMINAL.md` says to write it as `'\;'` in a raw `tmux send-keys`.

### Changed

- `implement`: when the reviewer proposed a fix for a finding that goes to the user as a question, one option is that fix in the reviewer's own words.

## [0.8.0] - 2026-09-29

### Added

- `qa`: a bundled `scripts/tui.sh` drives a terminal program in tmux. `start` launches it from a script, so no long command line is typed into the pane, with tabs as spaces and a pane that outlives it. `wait` polls until the expected text shows, with a time limit, and prints the screen without its blank rows and with icons named by code point, and `gone` polls until text leaves the screen. `keys` pauses after `Escape`, so a Bubble Tea app does not read the next key as Alt+key, and sends a key that starts with a dash as text instead of a tmux flag, and `show` and `stop` do the rest, so a QA pass no longer needs fixed sleeps or shell functions of its own. The skill names the one `tui` function to call it by, which zsh runs where a command stored in a variable fails. Cleanup deletes `$DIR` by its literal path and is done only when `tmux ls` lists none of its sessions, and a blocked cleanup is reported as leftover state, so a stale session no longer reaches the next QA pass. A layout is judged to fit by the frame's right border at the pane's edge, since tmux clips a row that is too wide and counting a row's characters cannot find it.

### Changed

- `code-review`: the Duplicated Code smell also flags a new hunk that repeats a function already outside the diff, and reports how many copies the codebase holds in total, and the wait for the Adversarial peer runs in short sleeps, so its completion notice is not held behind one long sleep. A P2 or P3 that quotes its line counts as verified without the validator, so it stays in the open findings until it is fixed.
- `implement`: every question to the user about a review finding lists its options with their costs and ends on a recommendation, so the user can answer with an option code. Every check runs bare, during slices too, so no filter after it can hide a red exit status.

## [0.7.3] - 2026-09-29

### Changed

- `implement`: a verified review finding the agent judges not worth fixing goes to the user as a question with its reason, so every finding ends fixed or asked.
- `qa`: a terminal capture names each Nerd Font icon by its code point, through a one-line `ruby` filter, so icons can be told apart.

## [0.7.2] - 2026-09-28

### Fixed

- `qa`: QA writes the diff to `$DIR/diff.patch` and reads that file, so a shell hook that shortens terminal output no longer truncates it. Before it launches a program that redraws the screen, it runs `stty oxtabs`, so captures carry spaces instead of tabs. It launches a terminal program with `exec` in a pane that stays after exit, so a crash leaves its last screen for capture and later keys no longer reach a shell prompt, and it reads the exit status from `#{pane_dead_status}`.

## [0.7.1] - 2026-09-28

### Fixed

- `qa`, `implement`: QA reports its fails to the caller and files, comments on, and labels no issue, so a fail in unmerged work goes back to `implement` to fix, not to the tracker as a ticket.

## [0.7.0] - 2026-09-28

### Added

- `qa`: QA a change in the running program before code review. It writes a scenario for every requested behavior and every user-reachable path the diff changes, drives a terminal program through tmux and a web app through a browser tool, and reports each scenario as pass, fail, or blocked with the evidence it observed. A terminal program runs every scenario in a big (215x60) and a small (80x24) terminal, gets its environment on the typed command, since the session's login shell rebuilds `PATH`, and a scenario that measures widths turns tabs into spaces with `stty oxtabs` first.

### Changed

- `implement`: QA runs on the committed work before `code-review`, in a fresh sub-agent that gets only the fixed point, the spec, and the earlier fails. Each fail is fixed test-first until QA passes, and review fixes that change behavior get QA again before anything closes. The `code-review` report no longer ends the turn: fixing its findings follows in the same turn.
- `diagnosing-bugs`: the fix passes `qa` against the bug report before it is reviewed, and a fail goes back to Phase 3. Its upstream licenses move from `CREDITS.md` into a `NOTICE` file.
- `tdd`: `mutate.sh` moves its exit cleanup into one function, with no change in behavior. A test now checks that an interrupted run stops TEST, restores the target, and removes its backup. The upstream license moves from `CREDITS.md` into a `NOTICE` file.
- `code-review`, `codebase-design`, `grilling`, `ideate`, `pr`, `qa`, `retro`, `setup-supermatt-skills`, `to-questionnaire`, `to-tickets`: each scans clean with skillspector, with no change in behavior. Upstream licenses move from `CREDITS.md` into a `NOTICE` file, credit links point at the upstream skill's directory, and sentences the scanner misread are reworded.

### Fixed

- `setup-supermatt-skills`: the domain docs it writes say ADRs live in `docs/adr/` once the first one is written, so an agent in a repo without ADRs no longer runs `ls docs/adr` and gets an error.

## [0.6.4] - 2026-09-27

### Fixed

- `code-review`: the diff now includes untracked files, uncommitted work on the default branch reviews against `HEAD` without asking, and requirements settled in the conversation count as a spec source.
- `diagnosing-bugs`: the review's P0 and P1 fixes follow in the same turn as the aggregate, and a debug probe that prints nothing is checked for placement before its output channel.
- `grilling`: a question's disputed premise is settled with direct evidence before the decision goes back to the user, and a round holds no question another question in it would answer or reshape.
- `ideate`: the Take it further prompt keeps the `grill-with-docs` command even though that user-only skill never appears in the skill listing.
- `implement`: the frontier pick takes only `ready-for-agent` tickets with code left and stops when none remain, and the lint runs after every green tdd cycle and review fix.
- `prototype`: the throwaway branch is pushed when the repository has a remote, and UI prototypes outside the browser get a flag, a key, and a PROTOTYPE bar in place of the web switcher.
- `retro`: a regular file under the home directory is checked for a sync from a repository before it is called hand-edited, and the transcript search starts from a tested `jq` query for failed tool calls.
- `setup-supermatt-skills`: Step 3 prints every draft before asking whether to write the files.
- `tdd`: code the change needs behind an unconfirmed seam waits for that seam to be confirmed, and mutation covers every file the run changed.
- `triage`: the issue or PR is read with the tracker config's own read command, after reading that config in its own call.
- `wayfinder`: the challenge runs before any confirmation and goes to the user as one question, and repository files a resolution changes are committed without asking.

## [0.6.3] - 2026-09-27

### Fixed

- `tdd`: `scripts/mutate.sh` kills a mutation's TEST, and every process TEST started, after `-t SECONDS` (by default five times the unchanged run plus a minute), and reports it `timeout`. A mutation that made the code loop forever used to hold the batch until the test runner's own timeout, and left a child of the runner spinning after it. The script now needs `perl`.

## [0.6.2] - 2026-09-27

### Fixed

- `to-tickets`: a ticket's Seams list every seam from the spec's Testing Decisions that one of its acceptance criteria crosses, so a ticket with a UI criterion names the UI seam too.

## [0.6.1] - 2026-09-26

### Added

- `PRIVACY.md`: SuperMatt collects nothing itself, and the policy lists each skill that passes data to another tool or service. `plugin.json` links it as `privacyPolicyUrl`.

## [0.6.0] - 2026-09-26

### Deprecated

- `wizard`: deprecated with no replacement. Its template is gone, and the skill is now a stub that says so. SuperMatt 0.7.0 removes it.

### Fixed

- `diagnosing-bugs`: the human-in-the-loop template reads each answer straight into its variable, so it no longer builds a shell command from the user's answer.
- `tdd`: the mocking reference's hard-to-mock example no longer reads an API key from the environment, which the Claude plugin directory held as a credential leaving the machine.
- The plugin ships its logo as its icon and sets `displayName` and `keywords` in `plugin.json`, so the Claude plugin directory lists it as SuperMatt with its own icon.

## [0.5.10] - 2026-09-26

### Fixed

- `tdd`: a mutation batch running in the background needs the working tree left alone until it exits, since `mutate.sh` rewrites each target in place and restores it from a copy, so an edit made meanwhile is lost or skews the results.

## [0.5.9] - 2026-09-26

### Fixed

- `retro`: a hook rule is found through the hook's own tool (its usage text, or a subcommand that prints the ruleset), so a retro no longer searches the home directory by content, which holds every session transcript and times out.

## [0.5.8] - 2026-09-26

### Fixed

- `code-review`: with no fixed point given on a branch other than the default branch, the review diffs against the default branch and says so in one line, and asks only on the default branch itself. Fixture files for the Adversarial axis are written with the file-writing tool, the shell kept for `mkdir`, `git`, and `ln`, so a hook that blocks shell redirects does not stop the setup.
- `implement`: lint runs with typechecking after each slice of work, so a lint failure no longer waits behind a full test suite at commit time.
- `tdd`: an equivalent mutation of code that has to stay is a listed survivor, with the input that could not tell it apart, and the mutation check is done when every mutation is red or a listed survivor. A mutation that removes a loop or recursion guard runs under the test runner's own time limit, and its timeout counts as red.

## [0.5.7] - 2026-09-26

### Fixed

- `pr`: the template's headings and labels are in sentence case (`Merge danger`, `Blast radius`), so a PR body passes a sentence-case heading check.
- `retro`: the sub-agent transcripts sit in the directory named after the session file, which after a resume differs from the session ID the environment reports.
- `tdd`: a mutation that keeps a name in use writes `x + 0` in place of a self-assignment `x = x`, which a vet step such as `go vet` reports `broken`.

## [0.5.6] - 2026-09-26

### Fixed

- `code-review`: the same-model fallback for the Adversarial axis leaves its scratch state under the review's temp directory for the final step to delete. A cleanup `rm` can stop on a permission prompt, and the validator needs that state to rerun a trigger.

## [0.5.5] - 2026-09-26

### Fixed

- `code-review`: the diff is written once to a file in the review's temp directory and every sub-agent reads that file, since a shell hook can shorten a diff printed to the terminal. A reviewer reads a file the diff adds from the diff itself, and reads surrounding context by line range. The same-model fallback for the Adversarial axis may write scratch state under the review's temp directory to run triggers, which the read-only peer cannot.
- `implement`: a verified review finding whose cause lies outside the repo goes to the user as a question with a recommendation, like one whose fix would reverse the spec.
- `retro`: a candidate that edits a file outside the repo names that file's source first, so it never proposes a hand edit to a file a tool generates.
- `tdd`: a large mutation batch runs in the background, since BUILD and TEST run once per mutation and dozens of them can outlast the shell tool's time limit.

## [0.5.4] - 2026-09-26

### Fixed

- `tdd`: after a `broken` mutation, the mutation runner prints a hint on stderr: when the build rejects a name the mutation left unused, keep it in use with `false && cond`.

## [0.5.3] - 2026-09-26

### Fixed

- `code-review`: the peer's program is built before its prompt is written, so the prompt carries the binary's path from the start and is written with the file-writing tool. The aggregate keeps each finding's severity, `file:line`, and quoted line.
- `implement`: every verified review finding is fixed on the branch, at every severity, unless its fix would reverse the spec. A ticket's parent is read only in the sections the ticket points to or the work needs, on every path, not only the frontier one.
- `retro`: the current session's transcript is the newest `.jsonl` in the project's directory, whose name differs from the session ID after a resume.
- `tdd`: the mutation runner first runs BUILD and TEST on the unchanged code and stops with exit 2 when either fails. A TEST that was already red, such as `go test -run A|B` once `sh` reads the `|` as a pipe, no longer reports every mutation red. A build failure or a panic is not red, and a test calling a name that does not exist yet gets a stub that returns the zero value until its assertion fails.

## [0.5.2] - 2026-09-25

### Fixed

- `code-review`: each finding gives one fix. When more than one fits, it recommends one and names the trade-off, so a fix-applying step no longer stalls on an unranked choice.

## [0.5.1] - 2026-09-25

### Fixed

- `to-spec`: the run reads the tracker doc first and fetches the reference through its **Read an issue** command. The fresh-context check also flags decisions that contradict the map's decision record or settle what it never settled. A spec from a `wayfinder` map names the map as its parent, and publishing it links the spec on the map and closes the map.

## [0.5.0] - 2026-09-25

### Added

- `code-review`: a validator sub-agent checks every P0 and P1 before the verdict. It confirms, rejects, or leaves each finding unresolved, and rejects a security, data-loss, or concurrency finding only with a refuting line or test result. A rejected finding moves to its axis's "Dropped by verification" line, so one false P0 no longer blocks a change. The Standards axis gains a test check for behavior no test exercises and for tests that pass with the code broken. The finding rules skip problems a guard already handles and code under a lint-ignore, count a newly relevant unchanged line, and ask each finding to lead with its effect. The Adversarial brief looks for masked failures: a reused sentinel, a swallowed error, a flag the error path never clears (adapted from Every's `ce-code-review`).

## [0.4.5] - 2026-09-25

### Fixed

- `implement`: the run reads the tracker doc first and fetches each ticket through its **Read an issue** operation. A parent it picks from is not read in full. The frontier is the children with an open-blocker count of 0, which **List children** now returns in one call.
- `setup-supermatt-skills`: the GitHub tracker's **List children** returns each child's count of open blockers in one paginated call.
- `retro`: user-global steering, hook rules, and installed skills count as environment. A candidate for a plugin-cache skill names its source checkout, or is marked upstream.
- `tdd`: an equivalent mutation is deleted like unreachable code. Rewriting code so a mutation no longer applies needs its own red case and a new mutation pass. The skill states the mutation file format and puts the files in a `mktemp -d` directory.

## [0.4.4] - 2026-09-24

### Fixed

- `code-review`: the refactor check flags a changed expected value for a behavior the commit still exposes, so a refactor that deletes tests of a removed or now-private subject, or moves them into boundary tests, passes. The temp directory is deleted once the Adversarial axis has a report, so a fallback after a failed peer still has its prompt. The fallback is told to read that `prompt.md`, and is no longer handed a prompt rebuilt by hand.

## [0.4.3] - 2026-09-24

### Fixed

- `code-review`: a peer that already failed in this session on a usage limit that has not reset goes straight to the fallback, instead of being launched again to fail the same way.
- `implement`: when a review asks for structural and behavior fixes, the structural ones are made and committed as `refactor:` first, so the two commits need no untangling afterwards.
- `tdd`: a cycle adds one case, not one test file, so each new case in a table or a script is seen red, since a runner that stops at its first failure hides every case after the first. A case the spec asks for over existing behavior is a characterization test, and counts once the code it covers is broken and it goes red.

## [0.4.2] - 2026-09-24

### Fixed

- `tdd`: the skill gives the command that runs `scripts/mutate.sh`, through `sh`, and the script is executable, so a direct call no longer fails with "permission denied".

## [0.4.1] - 2026-09-24

### Fixed

- `code-review`: the peer runs read-only, so the run creates any fixture or setup a trigger needs beside the built program before the peer starts, and names it in the prompt.
- `implement`: the full suite and lint run with the tool's longest timeout, since together they can outlast the default and move to the background.
- `retro`: step 2 dispatches a sub-agent to search every source outside the agent's context (the thread before a compaction and each sub-agent transcript), counts a repeated mistake across all of them, and ends on a completion criterion.
- `tdd`: a mutation keeps every import and variable in use, so a compiler that rejects unused names does not report it broken, and a green mutation gets a test that turns it red or its unreachable code is deleted. The check is done when every mutation is red.

## [0.4.0] - 2026-09-24

### Added

- `tdd`: `scripts/mutate.sh` runs the mutation pass. It applies each mutation alone, restores the file, and reports it red, GREEN, broken (the build step failed) or missing (its text was not found), so a session stops hand-writing that harness.

### Fixed

- `code-review`: the adversarial peer gets the path of a program built from `HEAD` in its temp directory, since a read-only peer cannot build and a binary already in the checkout may predate the change.

## [0.3.8] - 2026-09-24

### Fixed

- `code-review`: the peer runs as its own background shell call with no trailing `&`, so the call's completion notice says when `out.md` is ready.
- `implement`: the repo's lint runs with the full test suite before every commit, and the commit is chained on each check's own exit status, unpiped or under `pipefail`, so a red check stops it.
- `retro`: step 2 names what the agent's own context cannot hold, the thread before the last compaction and the sub-agent transcripts in `<session-id>/subagents/`, as the sources left to search.
- `tdd`: code written ahead of its test counts only once a mutation turns that test red, each branch waits for a failing case that runs it, and a mutation that only panics or fails to compile does not count as killed.

## [0.3.7] - 2026-09-24

### Fixed

- `code-review`: the adversarial prompt carries the test command the session ran and its result, since the read-only peer often cannot build, and the aggregate is printed as its own message with every finding under its axis, also when another skill loaded the review.
- `implement`: on the default branch it creates a branch before it commits, and asked for a parent's next ticket it lists the children through the tracker's **List children** operation and reads the picked ticket in full, opening the parent only where the ticket points to it.
- `retro`: a candidate passes the filter only when it is grounded, naming the moment in the session where the friction showed, with any steering file it cites governing the path the session took.
- `setup-supermatt-skills`: the GitHub tracker template reads an issue or a pull request through `--json`, because a piped `--comments` prints the comments alone without the body, and it adds a **List children** operation for the issues whose `## Parent` section names a parent.
- `tdd`: a behaviour-preserving change reads `characterization.md`, where existing tests are the characterization tests and each refactor step runs the break check (a pure move is checked by diffing the moved lines), and the glossary covers every identifier a change introduces.

## [0.3.6] - 2026-09-24

### Fixed

- `implement`: asked for the next ticket under a parent spec, it takes the first frontier ticket (an open child whose blockers are all closed) and names it, and it closes an issue only once its commits are merged into the default branch.
- `setup-supermatt-skills`: a repo whose glossary is still `CONTEXT.md` keeps that name by default, with a rename offered second and preceded by a reference search; an existing `docs/agents/` file is diffed against its template and its repo-specific lines carried over; and the `domain.md` template states which layout the repo uses.

## [0.3.5] - 2026-09-24

### Fixed

- `to-spec`: a wayfinder map whose destination is already written is read from that destination, with a linked ticket fetched only where it is silent, and the template names the durable paths a spec may cite (a document it builds on, prior-art tests) in place of banning every path.
- `to-tickets`: a ticket lists only its direct blockers, dropping an edge another blocker already implies.
- `wayfinder`: a Decisions-so-far entry is one sentence of at most 30 words, stated in the template and at the step that writes it, so the map stays a low-resolution index as it grows, and a Notes skill tied to a condition is called when the work meets it.

## [0.3.4] - 2026-09-24

### Fixed

- `diagnosing-bugs`: the HITL script runs in POSIX `sh`, so it no longer needs bash on the user's machine.

## [0.3.3] - 2026-09-23

### Changed

- The plugin description in the Claude Code catalog now matches the README opening sentence.

## [0.3.2] - 2026-09-23

### Fixed

- `architecture-review`: names the `codebase-design` skill without a slash in its own instructions.
- `ask-supermatt`: keeps `/to-spec` specs out of triage along with `/to-tickets` tickets, points the prototype at the issue that asked the question, and sends questionnaire answers to `/grill-with-docs`.
- `code-review`: a refactor check hit is P1, and the issue references it reads no longer list a GitLab merge request.
- `diagnosing-bugs`: records the commit before the fix, commits the regression test and the fix after the full suite passes, and gives `code-review` the bug report, written to a file, as the spec. It fixes and commits verified P0 and P1 findings, and leaves the review to an outer flow such as `implement`. The HITL script is linked as a bundled file.
- `domain-modeling`: the glossary format includes the optional `## Relationships` section.
- `grill-with-docs`: "ADRs" in the description.
- `handoff`: the save-location sentence no longer uses a spaced hyphen as a dash.
- `implement`: works a triaged pull request on its head branch, stops when it cannot push there, and leaves the pull request open. It treats the seams of a refactor or a review fix as pre-agreed, and closes issues once every review axis completed and every verified P0 and P1 finding is fixed. It asks for `/setup-supermatt-skills` when the tracker file is missing, and accepts triaged issues as well as tickets.
- `retro`: its Skill tool call uses the quoted form, and its Codex description drops the trailing period.
- `setup-supermatt-skills`: lists GitLab among the supported trackers, and names every skill that reaches `domain-modeling`.
- `tdd`: a refactor may rename or move a test file, as in `implement` and `code-review`.
- `teach`: sentences that used a spaced hyphen as a dash are rewritten, and learning records point at `MISSION.md` and `TERMS.md` by path, not wiki links.
- `to-spec`: reads the tracker and label files by path, so Codex finds them when setup wrote only `CLAUDE.md`. It asks the user only the seam check and any review finding that needs a decision.
- `to-tickets`: reads the tracker and label files by path. Tickets carry `Status:` and `Blocked by:` lines at the top, in the tracker's format. It takes `ready-for-agent` off the parent spec, then stops and sends the user to `/implement` in a fresh context.
- `triage`: reads the tracker and label files by path, and agrees the seams before every move to `ready-for-agent`, including a quick override, so agent briefs record them. Its queue leaves out specs, tickets, and `wayfinder` issues, and briefs no longer assume GitHub.
- `wayfinder`: reads the tracker file by path, works each ticket by its type, and claims and resolves through the tracker's operations. It builds non-code prototypes itself, sizes tickets to the smart zone, and hands a finished map to `/to-spec`.

## [0.3.1] - 2026-09-23

### Fixed

- `code-review`: no longer claims the `claude` peer runs on the default model; `--safe-mode` keeps the user's model selection.
- `ideate`: frame agents get their assigned frames (the fourth takes three), and the Scope question goes through the harness's multiple-choice tool when it has one.
- `wizard`: GitHub variables are a named destination, and the static trace checks every `set_var` name against a `vars.*` reference.
- `triage`: a quick override to `ready-for-agent` on a PR writes the agent brief that state requires.
- `tdd`: the call-count red flag covers internal collaborators only, so a retry-count test at a system boundary no longer contradicts it.
- `prototype`: a logic demo that checks persistence uses `localStorage`, since it has no server.
- `writing-for-agents`: says hosts shorten or drop descriptions when the skill listing overflows, instead of claiming they always stay loaded.
- `grilling`: a round whose questions all have short options goes through the harness's multiple-choice tool when it has one.

## [0.3.0] - 2026-09-23

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

## [0.2.1] - 2026-09-23

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

## [0.2.0] - 2026-09-23

### Added

- `retro` (user-invoked): review a finished coding session and suggest changes to the agent's environment. Imported from mattpocock/skills.
- `pr` (model-invoked): the shape of a pull request body. Imported from mattpocock/skills, with the `show-me` MIT notice in its `CREDITS.md`.

### Fixed

- `ask-matt` no longer says the `diagnosing-bugs` post-mortem hands off to `improve-codebase-architecture`.
- `domain-modeling`: the `GLOSSARY-MAP.md` example now opens with a `# Glossary Map` heading.

## [0.1.0] - 2026-09-23

### Added

- Claude Code and Codex marketplaces for the plugin and its 25 engineering and productivity skills.

[unreleased]: https://github.com/svyatov/supermatt/compare/v0.8.2...HEAD
[0.8.2]: https://github.com/svyatov/supermatt/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/svyatov/supermatt/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/svyatov/supermatt/compare/v0.7.3...v0.8.0
[0.7.3]: https://github.com/svyatov/supermatt/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/svyatov/supermatt/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/svyatov/supermatt/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/svyatov/supermatt/compare/v0.6.4...v0.7.0
[0.6.4]: https://github.com/svyatov/supermatt/compare/v0.6.3...v0.6.4
[0.6.3]: https://github.com/svyatov/supermatt/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/svyatov/supermatt/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/svyatov/supermatt/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/svyatov/supermatt/compare/v0.5.10...v0.6.0
[0.5.10]: https://github.com/svyatov/supermatt/compare/v0.5.9...v0.5.10
[0.5.9]: https://github.com/svyatov/supermatt/compare/v0.5.8...v0.5.9
[0.5.8]: https://github.com/svyatov/supermatt/compare/v0.5.7...v0.5.8
[0.5.7]: https://github.com/svyatov/supermatt/compare/v0.5.6...v0.5.7
[0.5.6]: https://github.com/svyatov/supermatt/compare/v0.5.5...v0.5.6
[0.5.5]: https://github.com/svyatov/supermatt/compare/v0.5.4...v0.5.5
[0.5.4]: https://github.com/svyatov/supermatt/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/svyatov/supermatt/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/svyatov/supermatt/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/svyatov/supermatt/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/svyatov/supermatt/compare/v0.4.5...v0.5.0
[0.4.5]: https://github.com/svyatov/supermatt/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/svyatov/supermatt/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/svyatov/supermatt/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/svyatov/supermatt/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/svyatov/supermatt/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/svyatov/supermatt/compare/v0.3.8...v0.4.0
[0.3.8]: https://github.com/svyatov/supermatt/compare/v0.3.7...v0.3.8
[0.3.7]: https://github.com/svyatov/supermatt/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/svyatov/supermatt/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/svyatov/supermatt/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/svyatov/supermatt/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/svyatov/supermatt/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/svyatov/supermatt/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/svyatov/supermatt/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/svyatov/supermatt/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/svyatov/supermatt/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/svyatov/supermatt/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/svyatov/supermatt/releases/tag/v0.1.0
