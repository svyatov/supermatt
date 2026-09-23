---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
argument-hint: "[spec path or ticket references]"
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Where possible, at pre-agreed seams, call the Skill tool with "tdd".

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "code-review" to review the changes since the commit you started from.

Commit your work to the current branch.
