---
name: tdd
description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests.
license: MIT
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle: consult them before and during the loop, not after.

When exploring the codebase, read the glossary (`docs/agents/domain.md` gives the layout; by default `GLOSSARY.md` at the root, if it exists) so test names and every identifier the change introduces match the project's domain language, and respect ADRs in the area you're touching.

For a bug whose cause is not yet known, call the Skill tool with "diagnosing-bugs" first: it finds the cause and brings the repro back here as the failing test.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification: "user can checkout with valid cart" tells you exactly what capability exists, and it survives refactors because it doesn't care about internal structure.

Before you write a test, name the **break** it catches: the production change that turns it red. If you cannot name one, the test observes no behavior yet; find the behavior first.

Read [tests.md](tests.md) for good and bad test examples before writing the first test, and read [mocking.md](mocking.md) before adding any mock or test double. Before any behaviour-preserving change, read [characterization.md](characterization.md): it pins code that has no tests, and checks that existing tests cover each change.

## Seams: where tests go

A **seam** is where a module's interface lives (the `codebase-design` term): tests cross it the way callers do and observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. Seams named in the spec or issue you are working from are already confirmed. No test is written at an unconfirmed seam. You can't test everything, so agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

Ask: "What's the public interface, and which seams should we test?"

When the shape of that interface is itself in question (how deep the module is, where the seam belongs, what the interface should expose), call the Skill tool with "codebase-design" for the vocabulary. It is the shared source of the module, interface, depth, seam, adapter, leverage and locality terms, and it is a reference to consult, not a session to run.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological**: the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec.
- **Change detector**: the test goes red only on a deliberate decision (a constant's value, the exact wording of a message, the source text of a script or doc) and stays green through real bugs. Assert the behavior that depends on the decision: "a failing call is tried 5 times, then gives up" in place of `expect(MAX_RETRIES).toBe(5)`.
- **Horizontal slicing**: writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead: one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the test first and run it. It is red when the assertion fails for the break you named. An error, a typo, or a failed import is not red yet: fix it and run again. A test that passes at once pins behavior that already exists. If the code predates this run, rewrite the test to name a break that is not there yet. If this run wrote the code ahead of the test, the test counts only once you break that code (the mutation check below) and watch it go red: do that before counting the cycle, then undo the break. Then write only enough code to pass it: every branch you add is one the failing case runs. A behavior the case does not reach (another input form, another case of the same rule, a later slice's rule) waits for its own red test, even when the natural implementation would cover it in the same edit. Don't anticipate future tests or add speculative features.
- **Green is the whole suite.** A cycle is green when the project's full test command passes, not only the new test. Report every failure by name, including failures you did not cause.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Mutate before you finish.** Break the code under test in small, realistic ways, one at a time: a wrong constant or argument, the wrong branch, a missing side effect, an empty return, a missing check for empty, zero, null, or bad input. Run the tests for that seam, then undo the change. Each mutation must turn at least one test red as the red rule above defines it, an assertion failing for that break: a mutation that only panics or fails to compile proves nothing, so pick another. One that stays green marks behavior no test protects. Run them through [`scripts/mutate.sh`](scripts/mutate.sh) (bundled with this skill; its header gives the mutation file format): it applies each one alone, restores the file, and reports it `red`, `GREEN`, `broken` (the `-b` build step failed) or `missing` (its text was not found).
- **Refactoring is not part of the loop.** It comes after the slice is green, usually on what review found (the `code-review` skill), with the tests left unchanged apart from a mechanical rename or move. A refactor runs no red-green cycle: the seam's existing tests are its characterization tests, and each refactor step is done when the whole suite is green and characterization.md's break check turns a test red on that step's changed code.
