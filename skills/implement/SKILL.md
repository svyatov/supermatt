---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
argument-hint: "[spec path or ticket references]"
disable-model-invocation: true
license: MIT
---

Implement the work described by the user in the spec or tickets.

Before you start, record the current commit with `git rev-parse HEAD`.

Where possible, at pre-agreed seams, call the Skill tool with "tdd".

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, commit your work to the current branch.

Then call the Skill tool with "code-review" to review the changes since the commit you recorded.

When the work is a refactor, or when you fix what the review found, keep behavior the same:

- If the code has no tests, pin its current behavior first: call the Skill tool with "tdd" and write the characterization tests it describes.
- Leave test files alone, except for a mechanical rename or move. A test that has to change means behavior changed.
- Commit structural and behavioral changes separately.
- When a step goes red, revert it and take a smaller step.
