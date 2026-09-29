---
name: implement
description: "Implement a piece of work based on a spec, tickets, or triaged issues."
argument-hint: "[spec path, or ticket or issue references]"
disable-model-invocation: true
license: MIT
---

Implement the work described by the user in the spec or tickets. Read `docs/agents/issue-tracker.md` first, then fetch each ticket you are given with its **Read an issue** operation and read it in full. A parent you are asked to pick from is not such a ticket: see below. If that file is missing, tell the user to run `/setup-supermatt-skills` (`$setup-supermatt-skills` in Codex). When the user names a parent spec and asks for its next ticket, take the first **frontier** ticket: an open child of that parent (a sub-issue, or an issue whose `## Parent` section names it; the tracker's **List children** operation lists them, with each child's count of open blockers, where it has one) whose open-blocker count is 0 and that carries the `ready-for-agent` label (`docs/agents/triage-labels.md` names its string), lowest number first. A ticket with no code left, because every criterion is already on the default branch or only a human step such as a release remains, is not frontier: name it and what it waits on, then take the next one. With no frontier ticket left, say so and stop. Name the ticket you picked before you start. When a ticket names a parent, read only the parent's sections the ticket points to or the work needs, with the tracker's **Read a section** operation where it has one. With no spec or issue, the decisions settled in this conversation are the spec: write them to a file in the OS temporary directory, so the review can check against them.

When the issue is a pull request, check out its head branch first, and push your commits back to it. If the push is refused (a fork that does not allow maintainer edits), stop and tell the user.

Before you start, record the current commit with `git rev-parse HEAD`.

Where possible, at pre-agreed seams, call the Skill tool with "tdd". Seams that the spec or issue names are pre-agreed, and so are the seams of code you refactor and of a review finding you fix.

Run typechecking and the repo's lint after each slice of work, so the linter shapes the code as it is written. A slice is each green tdd cycle and each fixed review finding. A slice is done only once the lint has run on it: the tests alone do not count. Before every commit, run the lint and then the full test suite, chaining the commit on each check's own exit status (`&&`) so a red check stops it. Run every check bare, during slices too, so its exit status and failing lines are its own. Give that call the tool's longest timeout, since a full suite plus lint can outlast the default and move to the background.

Once done, commit your work to the current branch; on the default branch, create a branch first, named by the repo's convention. Reference each issue it implements in the commit message (`#<n>`, or the file path on a local tracker).

Then QA the changes since the commit you recorded in a fresh context: this context wrote them, so it shares their blind spots. Spawn one sub-agent that calls the Skill tool with "qa", and give it only that commit as the fixed point and the spec path or issue reference as the request, with no notes or summary of your own. Tell it to report back to you without editing any file or filing any issue. On each later pass, also give it the earlier fails, with their steps, as scenarios it must run. Without sub-agents, call the Skill tool with "qa" yourself. Fix each fail test-first (call the Skill tool with "tdd"), commit the fix the same way as the work, and QA again until the verdict has no fail. Name each blocked scenario, and what it needs, in your final message.

Then call the Skill tool with "code-review" to review the changes since the commit you recorded, and give it the spec or issue as the spec. Its report is not the end of this skill: continue to the next step in the same turn.

Fix every verified finding the review reports on this branch, at every severity, and commit the fixes the same way as the work. Two kinds of finding go to the user as a question instead: one whose fix would reverse something the spec asked for, and one whose cause lies outside this repo (an agent, service, or library working as designed), so no change here removes it. Every other finding ends fixed or asked: one you judge not worth fixing (a one-caller helper, a local convention) goes to the user as a question too. Put each question as options (O1, O2, ...), each with what it does and what it costs. When the reviewer proposed a fix, one option is that fix in the reviewer's own words. End the question on the option you recommend and the deciding reason, so the user can answer with a code.

When the review is clean (verdict **Ready**, or every axis completed and every verified P0 and P1 finding is fixed), close each issue you implemented through the tracker's Close operation. A pull request stays open for a human to merge. A closed issue is what unblocks the tickets that wait on it, so close it only once its commits are merged into the default branch. Until then, leave the issue open and tell the user the close waits on the merge.

When the work is a refactor, or when a review fix only restructures code, keep behavior the same:

- If the code has no tests, pin its current behavior first: call the Skill tool with "tdd" and write the characterization tests it describes. Commit them on their own (`test:`) before the refactor.
- Commit the structural change as `refactor:`, and leave test files alone in it, except for a mechanical rename or move. A test that has to change means behavior changed.
- Tests that the design agreed are superseded by tests at a deepened interface are deleted in their own commit, not a `refactor:` one, once the new tests are green.
- When a step goes red, revert it and take a smaller step.

A review fix that has to change behavior (a bug or a spec gap) goes test-first: call the Skill tool with "tdd". Once such fixes are committed, QA again before you close anything. When the review asks for both kinds, fix the structural findings first and commit them as `refactor:`, then make the behavior fixes on top of that commit.
