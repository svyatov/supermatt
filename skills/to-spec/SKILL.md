---
name: to-spec
description: "Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
argument-hint: "[wayfinder map or issue reference]"
license: MIT
---

This skill takes the current conversation context and codebase understanding and produces a spec. Synthesize what you already know instead of re-grilling the idea: you ask the user only the seam check in step 2 and any step 4 finding that needs a decision.

If the user passes a reference, fetch it through the issue tracker first. For a `wayfinder` map, also fetch every ticket its **Decisions so far** section links: those tickets hold the decisions the spec collapses into a plan.

Read `docs/agents/issue-tracker.md` and `docs/agents/triage-labels.md`. If either is missing, tell the user to run `/setup-supermatt-skills` (`$setup-supermatt-skills` in Codex).

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better: the ideal number is one.

Check with the user that these seams match their expectations.

3. Write the spec using the template below. Don't publish it yet.

4. Check the draft in a fresh context. This context wrote the spec, so it shares the spec's blind spots. Spawn one sub-agent with the draft and repo access, and this brief: "Report: (a) places where the spec contradicts itself, or a user story conflicts with an implementation decision or Out of Scope; (b) implementation decisions that the current codebase cannot support as written, citing the file; (c) user stories that no implementation or testing decision covers. Quote the spec line for each finding. Under 300 words."

Fix the findings that have one clear fix. A finding that needs a decision goes to the user before you publish.

5. Publish the spec to the project issue tracker. Apply the `ready-for-agent` triage label: it needs no further triage.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype, citing its `prototype/<name>` branch. Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- The seams under test, as agreed with the user in step 2
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
