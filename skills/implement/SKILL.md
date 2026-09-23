---
name: implement
description: "Implement a piece of work based on a spec, tickets, or triaged issues."
argument-hint: "[spec path, or ticket or issue references]"
disable-model-invocation: true
license: MIT
---

Implement the work described by the user in the spec or tickets. Fetch each issue you are given through the workflow in `docs/agents/issue-tracker.md` and read it in full. If that file is missing, tell the user to run `/setup-supermatt-skills` (`$setup-supermatt-skills` in Codex). With no spec or issue, the decisions settled in this conversation are the spec: write them to a file in the OS temporary directory, so the review can check against them.

When the issue is a pull request, check out its head branch first, and push your commits back to it. If the push is refused (a fork that does not allow maintainer edits), stop and tell the user.

Before you start, record the current commit with `git rev-parse HEAD`.

Where possible, at pre-agreed seams, call the Skill tool with "tdd". Seams that the spec or issue names are pre-agreed, and so are the seams of code you refactor and of a review finding you fix.

Run typechecking regularly, and the full test suite before every commit.

Once done, commit your work to the current branch. Reference each issue it implements in the commit message (`#<n>`, or the file path on a local tracker).

Then call the Skill tool with "code-review" to review the changes since the commit you recorded, and give it the spec or issue as the spec.

When the review is clean (verdict **Ready**, or every axis completed and every verified P0 and P1 finding is fixed), close each issue you implemented through the tracker's Close operation. A pull request stays open for a human to merge. A closed issue is what unblocks the tickets that wait on it.

When the work is a refactor, or when a review fix only restructures code, keep behavior the same:

- If the code has no tests, pin its current behavior first: call the Skill tool with "tdd" and write the characterization tests it describes. Commit them on their own (`test:`) before the refactor.
- Commit the structural change as `refactor:`, and leave test files alone in it, except for a mechanical rename or move. A test that has to change means behavior changed.
- Tests that the design agreed are superseded by tests at a deepened interface are deleted in their own commit, not a `refactor:` one, once the new tests are green.
- When a step goes red, revert it and take a smaller step.

A review fix that has to change behavior (a bug or a spec gap) goes test-first: call the Skill tool with "tdd". Commit it separately from structural changes.
