---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along three axes: Standards (does the code follow this repo's documented coding standards?), Spec (does the code match what the originating issue/spec asked for?), and Adversarial (how does the change fail in production?). Runs the reviews in parallel sub-agents and reports them side by side with a verdict. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
argument-hint: "[fixed-point] [spec-path]"
metadata:
  credits-skill: ce-code-review
  credits-author: Every
  credits-url: "https://github.com/EveryInc/compound-engineering-plugin/tree/main/skills/ce-code-review"
license: MIT
compatibility: Uses the codex CLI (from Claude Code) or the claude CLI (from Codex) for the Adversarial axis when installed.
---

Three-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?
- **Adversarial**: how does the change fail in production? A different model runs this axis when one is installed, because sub-agents of one model agreeing is one reading repeated.

All axes run as **parallel sub-agents** so they don't pollute each other's context. A validator sub-agent then checks every P0 and P1 with fresh eyes, and this skill aggregates what survives.

The issue tracker should have been provided to you. If `docs/agents/issue-tracker.md` is missing, tell the user to run `/setup-supermatt-skills` (`$setup-supermatt-skills` in Codex).

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one and HEAD is on a branch other than the default branch, the fixed point is the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, minus its `origin/`): name it in one line and carry on. On the default branch itself, ask.

Resolve the merge-base once with `git merge-base <fixed-point> HEAD`, create a fresh `mktemp -d` directory (`$DIR` below), and write the diff into it: `git diff <merge-base-sha> > "$DIR/diff.patch"` (against the merge-base, and including uncommitted changes to tracked files). That file is the diff every sub-agent reads: a shell hook can shorten a diff printed to the terminal, and a redirected one lands on disk whole. Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside three parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, a local issue file path, etc.), fetched via the workflow in `docs/agents/issue-tracker.md`.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

The Standards axis also carries one **refactor check**, a hard finding. A commit that its message marks as a refactor (`refactor:` in Conventional Commits) must not change an assertion's expected value for a behavior the commit still exposes. Such a change altered behavior under a refactor label, or rewrote a test to match the new code. A test deleted because the commit removed its subject or made it private passes, and so does one moved into boundary tests of the new interface.

It also carries a **test check**, a judgement call:

- **Untested behavior**: the diff changes runtime behavior (a new branch, a state change, an error path, a changed contract) and no test in the diff exercises it.
- **Vacuous test**: a new or changed test would still pass with the code under test broken. It asserts only that nothing throws or that a value is truthy, computes its expected value with the code under test, or has a mock supply the result the code should produce.

Trivial accessors and edits that change no behavior pass.

### 4. Pick the Adversarial reviewer

The peer is the other model's CLI:

- `CLAUDECODE=1` is set: the host is Claude Code, so the peer is `codex`.
- Any of `CODEX_SANDBOX`, `CODEX_SESSION_ID`, or `CODEX_THREAD_ID` is set: the host is Codex, so the peer is `claude`.

Confirm the peer is installed with `command -v <peer>`. When the host is unknown, the peer is missing, or the peer already failed in this session on a usage limit whose reset time has not passed, the Adversarial axis runs as a normal sub-agent instead (the **fallback**); note the reason for the report.

Before the peer starts, tell the user one line: "Adversarial axis: sending the diff to <peer>." This is a notice, so carry on without waiting for a reply.

### 5. Spawn the sub-agents in parallel

Every sub-agent prompt includes the **finding rules** (see _Finding rules_) pasted in full.

**Standards sub-agent prompt** should include:

- The diff file path and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline, the refactor check, and the test check from step 3** pasted in full (the sub-agent has no other access to them).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); (b) any baseline smell you spot: name it and quote the hunk; (c) any refactor check hit: name the commit and the test file; and (d) any test check hit: quote the untested behavior or the vacuous assertion. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, refactor check hits are hard, but baseline smells and test check hits are judgement calls, and a documented repo standard overrides the baseline. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff file path and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

**Adversarial prompt** is the contents of [ADVERSARIAL.md](ADVERSARIAL.md), then the finding rules, then the diff file path and commit list, then the test command this session ran and its result (the peer runs read-only and often cannot build), then, when the repo builds a program, the path of one built from `HEAD` so the peer can run a trigger instead of only tracing it, then "Under 400 words." The fallback sub-agent gets this same prompt.

For the peer, first build the program in `$DIR` with the repo's own build command (a build binary already in the checkout may predate the change). Then write the prompt, with that binary's path already filled in, to `prompt.md` in that directory with the file-writing tool (Claude Code: Write). The peer cannot write anywhere, so it can only run a trigger whose state already exists: create any fixture, config, or first-run setup the program needs under that directory now, writing each file's contents with the file-writing tool as for `prompt.md` and keeping the shell for `mkdir`, `git`, and `ln`, and name it in the prompt. Then start the peer's command from the repo root, alongside the other sub-agents, as its own background shell call (Claude Code: `run_in_background: true`, with no trailing `&`), so the call's completion notice is the signal that `out.md` is ready:

- `codex`: `codex exec - --ignore-user-config --disable apps --disable plugins -C "$(git rev-parse --show-toplevel)" -s read-only -c 'approval_policy="never"' --ephemeral -o "$DIR/out.md" < "$DIR/prompt.md"`
- `claude`: it has no shell, so first append `$DIR/diff.patch` to `prompt.md` between `=== BEGIN DIFF ===` and `=== END DIFF ===` lines. Then run `claude -p --safe-mode --strict-mcp-config --tools Read Grep Glob --permission-mode dontAsk --no-session-persistence < "$DIR/prompt.md" > "$DIR/out.md"`. When the Codex sandbox blocks its network access, request escalated permissions for this one command.

Each flag set keeps the peer read-only, with no MCP servers, plugins, or approval escalation, so it cannot write through the user's own config. The `codex` flags also skip the user's `config.toml`, so that peer runs on the CLI's default model; `claude --safe-mode` keeps the user's model selection.

Wait for the peer before step 6. When it exits non-zero, leaves `out.md` empty, says it could not read or review the diff, or has not finished 15 minutes after it started, stop it and run the fallback sub-agent, noting the reason. Its prompt is two lines: read `$DIR/prompt.md` in full and follow it, since that file already holds the whole prompt; and, unlike the peer, it may write scratch state under `$DIR` to run triggers (file contents through the file-writing tool, the shell for `mkdir`, `git`, and `ln`) and leaves it there for step 7 to delete, and it leaves the repository unedited. When the fallback fails too, the Adversarial axis is **incomplete**.

### 6. Verify P0 and P1 findings

Number every quoted P0 and P1 finding from every axis. When there are none, skip to step 7. Otherwise spawn one validator sub-agent whose prompt is the contents of [VALIDATOR.md](VALIDATOR.md), then the numbered findings with their axis, quote, and reasoning, then the diff file path and commit list.

Apply its verdicts to each finding on its own axis:

- **confirmed**: the finding stays as written.
- **rejected**: the finding leaves its axis and goes on that axis's "Dropped by verification" line with the validator's reason.
- **unresolved**: the finding stays with its severity, labelled `unresolved: <evidence still needed>`.

When the validator fails or leaves a finding without a verdict, that finding stays and is labelled `not validated`.

### 7. Aggregate

Delete `$DIR` first: nothing from here on reads it.

Present the reports under `## Standards`, `## Spec`, and `## Adversarial (<peer>)` headings, verbatim or lightly cleaned, keeping each finding's severity, `file:line`, and quoted line, each ending with its "Dropped by verification" line when step 6 dropped anything. When the fallback ran, the last heading is `## Adversarial (same model: <reason>)`. Do **not** merge or rerank findings, because the axes are deliberately separate (see _Why separate axes_). Print this aggregate as its own message before anything else continues, also when another skill loaded this one. Done when every finding from every axis appears under its heading or on its dropped line.

A **verified** finding quotes its line and was not rejected in step 6. End with a one-line summary: findings per axis by severity, then the verdict:

- Any verified P0 on any axis: **Not ready**.
- Otherwise, any verified P1 or an incomplete axis: **Ready with fixes**.
- Otherwise: **Ready**.

The verdict is a rule over severities. Don't pick a single worst finding across axes: that's the reranking the separation exists to prevent.

## Finding rules

- **Severity.** Tag every finding:
  - **P0**: breaks production, loses data, or opens a security hole.
  - **P1**: wrong behavior in normal use.
  - **P2**: a real problem with limited reach.
  - **P3**: minor.

  Baseline smells are P2 or P3. A refactor check hit is P1. A test check hit is P2.
- **Quote the line.** Every finding cites `file:line` and quotes the line it flags. A claim that something is missing quotes where it would be defined, and a race quotes both sides. A claim that nothing else calls or uses a symbol rests on a symbol-aware search (LSP, CodeGraph) when one is available, and otherwise says "grep-only". Label a finding without a quote `unverified`; it does not move the verdict.
- **Read by range.** Read the diff file in full, by line range when it is long. A file the diff adds is already in it whole; read other files by line range for the context around a hunk.
- **Lead with the effect.** Open each finding with what a user or caller sees, then give one fix. When more than one fits, recommend one and name the trade-off. When the right fix depends on something you can't see, propose the most likely default and name the assumption.
- **Skip:**
  - Code the diff didn't change, unless the diff makes it newly relevant (a new caller of an existing bug). Test: would you flag it on the same diff without the surrounding file?
  - A problem a caller, guard, or framework default already handles. Check them before you flag it.
  - Anything a linter, formatter, or type checker enforces, and code under a lint-ignore comment for that rule.
  - "Consider adding X" or "might break under load" with no concrete failure the diff makes reachable.
  - Needs the spec doesn't have yet.
  - Choices the code or spec marks as intentional.
- **Zero findings is a valid report.** Say so in one line.

## Why separate axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**
- Code that follows every standard and matches the spec but breaks on an input nobody listed → **Standards and Spec pass, Adversarial fail.**

Reporting them separately stops one axis from masking another.
