# Research report delivery

Date: 2026-10-15. Scope: the `research` skill's missing-report failure, not the unavailable findings from the earlier scouts.

## Observed facts

- The previous skill required one cited Markdown report, but assigned the work to a background agent without a parent-side file verification step. [Previous research skill](https://github.com/svyatov/supermatt/blob/085bfe80d5f6eb44c9c7b29dc4c397ab48c3f1a5/skills/research/SKILL.md#L7-L13).
- The public description already promises a cited Markdown file in the repository. Returning only chat findings does not meet that promise. [README](README.md#engineering).
- The existing research evaluation checks an explicit `research.md` destination. The added `research-handoff` case covers completed read-only scouts, an existing note directory, consolidation, and report readback. [Evaluation cases](tests/evals/cases.mjs).

## Inference and recommendation

The reported failure is consistent with unassigned writing responsibility when research is delegated to read-only scouts. The earlier transcript is unavailable here, so this does not establish why those particular scouts returned without a report.

Make one agent responsible for the file before dispatch. When scouts are read-only, the parent writes their combined findings. Before completion, the parent reads the saved report, checks its answer and citations, and returns its path. A blocked save is a blocker, not a completed research task. [Updated research skill](skills/research/SKILL.md).

The research question, source standards, invocation policy, and role in the planning flow remain unchanged. [Research skill](skills/research/SKILL.md), [router](skills/ask-supermatt/SKILL.md#standalone).

## Verification

Ran `bun scripts/evaluate-skills.mjs --model gpt-6.1-sol --baseline HEAD --cases research,research-handoff --variants neutral --runs 1` with Codex CLI 0.162.1, then reviewed each saved report and action trace against its rubric. Both candidate cases saved the required cited report, read it back after writing, preserved the inputs, and returned the file path. The original skill also passed both probes, so this run establishes no reduction in failure rate.

The requested model was `gpt-6.1-sol`; the trace did not report a model identity. The initial `gpt-5.4` attempt was rejected by the account before research ran. The completed probes used supplied local sources and completed scout summaries, not live parallel scouts. Claude runtime behavior was not tested.

Evidence: [completed evaluation and rubric decisions](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-QEMzC3/adjudicated-report.json), [candidate handoff action trace](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-QEMzC3/candidate-research-handoff-neutral-1/trace.jsonl), [rejected initial attempt](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-KETgi2/baseline-research-neutral-1/trace.jsonl). These retained artifacts are in the OS temporary directory.
