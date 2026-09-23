# SuperMatt Skills

Agent skills for coding agents. Run `/setup-supermatt-skills` once per repo before the first engineering flow.

## Install

In Claude Code:

```
/plugin marketplace add svyatov/supermatt
/plugin install supermatt@supermatt
```

Claude Code has a bundled `/code-review` skill with the same name as this plugin's `code-review`. Plugin skills are namespaced, so the plugin's review is `/supermatt:code-review`, and a bare `/code-review` runs the bundled one. To turn the bundled skill off, add this to your Claude Code settings:

```json
{ "skillOverrides": { "code-review": "off" } }
```

In Codex:

```
codex plugin marketplace add svyatov/supermatt
codex plugin add supermatt@supermatt
```

Maintainers working on this repo can instead link every skill into `~/.claude/skills` and `~/.agents/skills` with `scripts/link-skills.sh`. Linked skills are not namespaced, so in Claude Code a linked `code-review` replaces the bundled `/code-review`.

## Engineering

### User-invoked

- **[ask-matt](./skills/ask-matt/SKILL.md)**: Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[grill-with-docs](./skills/grill-with-docs/SKILL.md)**: Grilling session that also builds your project's domain model, sharpening terminology and updating `GLOSSARY.md` and ADRs inline.
- **[triage](./skills/triage/SKILL.md)**: Move issues through a state machine of triage roles.
- **[ideate](./skills/ideate/SKILL.md)**: Generate grounded ideas for what to build next, critique every one, and rank the survivors in a Markdown file, each with a prompt that takes it into `/grill-with-docs`.
- **[architecture-review](./skills/architecture-review/SKILL.md)**: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
- **[setup-supermatt-skills](./skills/setup-supermatt-skills/SKILL.md)**: Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo.
- **[to-spec](./skills/to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it to the issue tracker.
- **[to-tickets](./skills/to-tickets/SKILL.md)**: Break any plan, spec, or conversation into a set of tracer-bullet tickets, each declaring its blocking edges, whether as text in a local file or as native blocking links on a real tracker.
- **[implement](./skills/implement/SKILL.md)**: Build the work described by a spec or set of tickets, driving `/tdd` at pre-agreed seams, then committing and closing out with `/code-review`.
- **[retro](./skills/retro/SKILL.md)**: Run a retrospective on a coding session and get ranked suggestions for the agent's environment: automated checks, navigation pointers, coding-standards rules, stale or contradictory instructions, and a leaner `AGENTS.md`.
- **[wayfinder](./skills/wayfinder/SKILL.md)**: Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on the issue tracker, resolved one at a time until the way to the destination is clear.

### Model-invoked

- **[prototype](./skills/prototype/SKILL.md)**: Build a throwaway prototype to answer a design question: a single shareable HTML file for state/logic, or several toggleable UI variations.
- **[diagnosing-bugs](./skills/diagnosing-bugs/SKILL.md)**: Disciplined diagnosis loop for hard bugs and performance regressions: build a feedback loop that goes red on this bug → minimise → hypothesise → instrument → fix → regression-test.
- **[research](./skills/research/SKILL.md)**: Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file in the repo, run as a background agent.
- **[tdd](./skills/tdd/SKILL.md)**: Test-driven development with a red-green loop. Builds features or fixes bugs one vertical slice at a time.
- **[domain-modeling](./skills/domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model by challenging terms, stress-testing with scenarios, and updating `GLOSSARY.md` and ADRs inline.
- **[codebase-design](./skills/codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: small interfaces, clean seams, testable through the interface.
- **[code-review](./skills/code-review/SKILL.md)**: Three-axis review of the diff since a fixed point: **Standards** (does it follow the repo's coding standards, plus a Fowler smell baseline?), **Spec** (does it faithfully implement the originating issue/spec?), and **Adversarial** (how does it fail in production?), run as parallel sub-agents and closed with a verdict. When Claude Code runs the review, the Adversarial axis goes to `codex` if it is installed; when Codex runs it, the axis goes to `claude`.
- **[pr](./skills/pr/SKILL.md)**: The shape of a pull request body: a summary diagram or diff sketch, before/after evidence, and the merge danger (one-way or two-way door, blast radius).
- **[resolving-merge-conflicts](./skills/resolving-merge-conflicts/SKILL.md)**: Work through an in-progress git merge or rebase conflict hunk by hunk, resolving by intent traced to each side's primary source, then finish the operation, never `--abort`.
- **[wizard](./skills/wizard/SKILL.md)**: Generate an interactive bash wizard that walks a human through steps only they can perform: provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover.

## Productivity

### User-invoked

- **[grill-me](./skills/grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the design tree is resolved.
- **[handoff](./skills/handoff/SKILL.md)**: Compact the current conversation into a handoff document so another agent can continue the work.
- **[teach](./skills/teach/SKILL.md)**: Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[to-questionnaire](./skills/to-questionnaire/SKILL.md)**: Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can (filled in async, or together over a meeting).
- **[wait-what](./skills/wait-what/SKILL.md)**: Fire this the moment a message doesn't land. The agent re-pitches it with the context you're missing, in plain English, using your `GLOSSARY.md` vocabulary.

### Model-invoked

- **[grilling](./skills/grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the design tree is resolved.
- **[writing-for-agents](./skills/writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md/CLAUDE.md, and any doc an agent reaches by a pointer.

## Authors

- Leonid Svyatov
- Matt Pocock, author of the original skills in [mattpocock/skills](https://github.com/mattpocock/skills)

## License

MIT. See [LICENSE](./LICENSE).
