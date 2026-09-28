---
name: qa
description: "QA a change in the running program, the way its user meets it: drive a CLI or terminal UI through tmux, a web app through a browser, and check every requested behavior against what you observe. Use after implementing a change and before code review, or when the user asks for a QA pass, a smoke test, or a click-through of a change, or asks whether it actually works."
argument-hint: "[fixed-point] [spec-path]"
license: MIT
compatibility: Drives terminal programs through tmux, and web apps through whichever browser tool the session has (Chrome DevTools MCP, Claude in Chrome, Playwright MCP, or the host's own).
---

QA checks the running program against what was requested; tests check the code against what its author expected. A scenario passes only on a result you **observed** in the running program. A green suite, a read of the code, or an exit status on its own is not an observation.

QA runs before `code-review`: once QA shows the change does what was asked, the review can spend itself on how the code is written and how it fails.

QA reports and leaves the code as it found it. Scratch state goes in `$DIR`, a fresh `mktemp -d`. The caller fixes each fail, test-first, and runs QA again.

## Process

### 1. Pin the change and the request

The change is the diff since a fixed point: the one the caller or user names; else the default branch, when `HEAD` is on another branch; else `HEAD`, when the default branch has uncommitted work. Read the diff in full, and read each untracked file `git status --short` lists.

The request is what the change was meant to do: the spec or issue the caller passes, else the issue its commits reference, else the request settled in this conversation. With none, ask.

### 2. Write the scenarios

A **scenario** is one thing a user does and the result they should then see: the steps, and the expected result taken from the request. Write the list to `$DIR/scenarios.md` before you launch anything, covering:

- every requirement in the request;
- every user-reachable path the diff changes that the request never names (a new flag, a reworded message, a moved button);
- the unhappy paths of each: invalid or empty input, cancel or interrupt midway, the same action twice, a first run with no saved state;
- one existing flow that shares the changed code, to catch a regression next to the change.

Done when every requirement and every changed user-reachable path maps to at least one scenario.

### 3. Launch the program

Build and start it from the working tree with the repo's own commands (its README, `package.json` scripts, `Makefile`, or `--help`). Point it at scratch state: a directory under `$DIR`, a test database, a seeded test account, a local server. A scenario that can only run against real user data, a production service, or a live account is **blocked**: name what it needs and move on.

Pick the driver by the program's interface:

- A CLI or terminal UI: read [TERMINAL.md](TERMINAL.md).
- A web app: read [BROWSER.md](BROWSER.md).
- A library or HTTP API with no UI: call its public interface from a scratch script in `$DIR`, or with `curl`, the way its caller would.

### 4. Run every scenario

Do each step as the user would: type the command, press the keys, click, fill in the form, submit. After each step, read what the program shows and compare it with the expected result. Check the logs, stderr, and browser console for errors on every scenario, passing ones too.

Record each scenario in `scenarios.md` as **pass**, **fail**, or **blocked**, with its evidence: the captured screen, the output, a screenshot path, the error. A fail also records the steps that reproduce it, the expected result, and the observed one. A fail ends that scenario, not the run.

Done when every scenario has a status and its evidence.

### 5. Clean up and report

Stop everything you started: tmux sessions, servers, browser tabs. Delete `$DIR`, keeping only the screenshots the report cites.

Report one line per scenario (status, what it checked, the evidence or its path), then every fail in full, then the verdict:

- Any fail: **Fails QA**.
- Otherwise, any blocked scenario: **Passes with gaps**, naming each blocked scenario and what it needs.
- Otherwise: **Passes QA**.
