# Research report delivery

Date: 2026-10-15. Scope: the `research` skill's missing-report failure, not the unavailable findings from the earlier scouts.

## Observed facts

- The previous skill required one cited Markdown report, but assigned the work to a background agent without a parent-side file verification step. [Previous research skill](https://github.com/svyatov/supermatt/blob/085bfe80d5f6eb44c9c7b29dc4c397ab48c3f1a5/skills/research/SKILL.md#L7-L13).
- The public description already promises a cited Markdown file in the repository. Returning only chat findings does not meet that promise. [README](README.md#engineering).
- The existing research evaluation checks an explicit `research.md` destination. The added `research-handoff` case covers completed read-only scouts, an existing note directory, consolidation, and report readback. [Evaluation cases](tests/evals/cases.mjs).

## Inference and recommendation

The reported failure establishes missing report delivery. The earlier transcript is unavailable here, so it does not establish whether unclear writing responsibility caused that failure.

Keep the original dispatch and report-location rules. The caller owns completion: save any missing report from the cited findings, read the saved file, check its answer and citations, and return its path. A blocked save is a blocker, not a completed research task. [Updated research skill](skills/research/SKILL.md).

The research question, source standards, invocation policy, and role in the planning flow remain unchanged. [Research skill](skills/research/SKILL.md), [router](skills/ask-supermatt/SKILL.md#standalone).

## Verification

The initial comparison used `bun scripts/evaluate-skills.mjs --model gpt-6.1-sol --baseline HEAD --cases research,research-handoff --variants neutral --runs 1` with Codex CLI 0.162.1, followed by review of each saved report and action trace against its rubric. Both the original skill and the expanded fix passed both probes. That run establishes no benefit from the added pre-dispatch requirements.

The requested model was `gpt-6.1-sol`; the trace did not report a model identity. The initial `gpt-5.4` attempt was rejected by the account before research ran. The completed probes used supplied local sources and completed scout summaries, not live parallel scouts. Claude runtime behavior was not tested.

Evidence: [completed evaluation and rubric decisions](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-QEMzC3/adjudicated-report.json), [candidate handoff action trace](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-QEMzC3/candidate-research-handoff-neutral-1/trace.jsonl), [rejected initial attempt](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-KETgi2/baseline-research-neutral-1/trace.jsonl). These retained artifacts are in the OS temporary directory.

### Simplified workflow

After removing the pre-dispatch requirements, the same two cases were compared against commit `210fd2f`. The simplified candidate passed both: it saved one cited report, read it back after writing, preserved the source files, and returned the path. The expanded baseline saved both reports but skipped readback in the direct research case. This single comparison is not evidence of a lower failure rate.

Evidence: [simplified workflow evaluation](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-ozmkT3/adjudicated-report.json), [candidate handoff trace](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-ozmkT3/candidate-research-handoff-neutral-1/trace.jsonl), [baseline research trace](/private/var/folders/_j/rypdbl8n001d6g3dl5l7fjrm0000gn/T/supermatt-evals-ozmkT3/baseline-research-neutral-1/trace.jsonl).
