---
name: retro
description: "Conduct a retrospective on a coding session."
disable-model-invocation: true
argument-hint: "[session to review, defaults to this one]"
license: MIT
---

The user has asked for a **retrospective**. You are suggesting improvements to the coding agent's **environment** to improve future runs.

## Steps

1. Call the Skill tool with "writing-for-agents" for the writing style guide.

2. Read the primary sources for the session the user specifies. This may mean searching through session logs on this machine; hand that search to a sub-agent that returns only the relevant excerpts. Claude Code keeps sessions under `~/.claude/projects/` (or `$CLAUDE_CONFIG_DIR/projects/`), Codex under `~/.codex/sessions/` (or `$CODEX_HOME/sessions/`). If the user doesn't specify a session, default to the current one. Your context already holds its main thread up to the last compaction; the sources left to search are anything before that compaction and the sub-agent transcripts, which Claude Code keeps in `<session-id>/subagents/` beside the session file.

3. Look for candidates for improvement in these categories.

- **Navigation**: how easy was it for the agent to find the right files? Are there hidden dependencies between files? Would a **context pointer** make it easier? _Use when_ the session took a long time to find a piece of information.
- **Automated checks**: are there automated checks that could catch errors the agent made? Linting, typing, tests, filesystem linters? Read the repo's own check command first (its `package.json`/build-tool `lint`/`check` scripts, its CI workflow), so a check that already exists but sits unwired or silently broken is the finding, not a reinvention. A repo with no **guardrail** (no pre-commit hook and no CI job running its lint/typecheck/test command) is itself a finding: an un-linted repo is a standing missed opportunity, not a neutral default. _Use when_ the agent made a mistake an automated check could have caught, or the repo has no guardrail at all.
- **Coding standards**: should the **reviewer agent** be given a new rule to enforce? Should an existing rule be removed or clarified? Classify the violation first: a **mechanical** one (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) gets a deterministic check, full stop: a custom rule in the repo's own linter, a new pre-commit hook, or a new CI job, whichever the repo's language and existing guardrail make cheapest. Default to building the check over writing the rule. Reserve `CODING_STANDARDS.md` for genuine **judgement calls** (cross-file consistency, "matches the surrounding style," anything no guardrail could ever substitute for). _Use when_ the reviewer agent failed to catch a mistake.
- **Global AGENTS.md**: are there any steering instructions that should be moved to coding standards (or automated checks) instead? _Use when_ the AGENTS.md file is particularly large, in the repo OR the user's global scope.
- **Tool economy**: did the agent make expensive tool calls that could be streamlined? Is there any custom tooling (CLI's, MCP's) that is particularly token-inefficient? _Use when_ the agent made an expensive tool call.
- **Drift**: does a steering file the session read name a path, command, or rule the current code no longer supports? Do two steering files contradict each other? A contradiction ranks above plain staleness, because it actively misleads. Check only the steering files the session read; do not sweep the rest. _Use when_ the agent followed a stale pointer or got two conflicting instructions.
- **Duplication and no-ops**: look for instructions in steering files that don't modify the agent's behavior. Use the two `writing-for-agents` terms. **Duplication**: a named artifact already states the same rule in its own text (a lint rule, a test, a code comment, another steering file); quote that file and line. A file on a related topic is not coverage. **No-op**: the model already does it by default. _Use when_ the steering files are large and unwieldy.
- **Information access**: look for opportunities to increase the agent's access to information. Teeing dev server logs, readonly access to third-party services. _Use when_ a crucial piece of information was not available to the agent.

4. Filter the candidates. Keep only **grounded** ones: the candidate names the moment in the session where the friction showed (a call, an error, a correction), and when it cites a steering file, the section around the cited line governs the path the session took. Then keep one only if a future agent would plausibly repeat the mistake without the change, and the lesson is not already recoverable from the code, tests, types, comments, or existing docs. How long the session took or how bad it felt does not qualify a candidate. When a candidate touches an existing rule, doc, or check that was wrong or incomplete, amend that artifact instead of adding a new one.

5. Present the surviving candidates to the user, in order of severity. If none survive, say so and name why each was dropped.

## Reference

### Implementation vs Review

Remember that all work goes through two stages: implementation and review. The implementation agent has the most **context pressure**. They are responsible for exploration, writing code, and debugging failures.

The review agent has the least context pressure: it receives a diff, so no exploration needed. It often does not need to write code or debug.

This means that the review agent should be responsible for imposing coding standards, not the implementation agent.

### Files

You have access to several files in the repo:

- `CLAUDE.md`/`AGENTS.md`: these files are pushed to the context window of any agent working in this repo. They should be used incredibly sparingly, usually only for **context pointers** to other files.
- `CODING_STANDARDS.md`: this file is read during review, not implementation. Add **context pointers** to docs folders if the standards file gets more than 1,000 lines long.
- Docs: use docs as references files, pointed to by other files. Look for existing docs before writing new ones.
- Skills: use skills for docs (since their description goes into the agent's context window), or for user-invoked commands. Follow the advice in the `writing-for-agents` skill.
