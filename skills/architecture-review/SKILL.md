---
name: architecture-review
description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
disable-model-invocation: true
argument-hint: "[module, subsystem, or pain point]"
license: MIT
compatibility: Uses git to find hot spots. The HTML report loads Tailwind and Mermaid from cdn.jsdelivr.net, so viewing it needs network access.
---

# Architecture Review

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

This command is _informed_ by the project's domain model and built on a shared design vocabulary:

- Call the Skill tool with "codebase-design" for the architecture vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**, **information leakage**), its red flags, and its principles (the deletion test, "the interface is the test surface", "one adapter = hypothetical seam, two = real"). Use these terms exactly in every suggestion, and don't drift into "component," "service," "API," or "boundary."
- The domain language in `GLOSSARY.md` gives names to good seams; ADRs in `docs/adr/` record decisions this command should not re-litigate. `docs/agents/domain.md` gives where both live.

## Process

### 1. Explore

**Scope before you scan: YAGNI.** Deepening a module pays off by making future changes to it easier, so put extra weight on the parts of the codebase that have recently changed. Decide *where* to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take it, and skip the inference below.
- Otherwise, find the hot spots: files that change often and are complex. Count the changes per file over the last year with `git log --since="12 months ago" --name-only --pretty=format:`. Leave out bot commits and bulk reformat or move commits, because they inflate every file they touch. Rank the most-changed files by complexity, and let the top paths pull your attention first. If the changes are scattered with no clear hot spot, widen the net.

Read the project's domain glossary and any ADRs in the area you're touching first (`docs/agents/domain.md` gives the layout; by default `GLOSSARY.md` and `docs/adr/` at the root).

Then spawn a sub-agent to walk the codebase. Don't follow rigid heuristics; explore organically and note where you experience friction. Give the sub-agent the `codebase-design` red flags, and have it name each friction with a flag where one fits:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where is one design decision encoded in several modules (**information leakage**), especially where no interface shows it?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

Some modules are shallow by design: thin adapters, data classes with no logic, and configuration loaders. Skip them.

### 2. Assess

Tie each finding to the symptom a reader of the code meets:

- **Change amplification**: a simple change touches many places.
- **Cognitive load**: a reader must hold a lot in mind to change anything safely.
- **Unknown unknowns**: a reader cannot tell what they need to know. This is the worst of the three.

A finding with none of these symptoms is a preference. Drop it.

Then give a verdict:

- **Healthy**: only minor friction. Tell the user, name the friction, and stop. Write no report.
- **Localized**: one or two areas have real friction. Report at most two candidates.
- **Systemic**: friction is widespread. Report the candidates ranked.

If the user gives a reason to go on after a Healthy verdict, scope the report to their request.

### 3. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user (`xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows) and tell them the absolute path. In a remote or cloud session, where opening does nothing on the user's machine, send the file with the harness's file-sending tool if it has one (`SendUserFile` in Claude Code).

The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via CDN** for diagrams where a graph/flow/sequence reliably communicates the structure. Mix Mermaid with hand-crafted CSS/SVG visuals: use Mermaid when relationships are graph-shaped (call graphs, dependencies, sequences), and hand-built divs/SVG when you want something more editorial (mass diagrams, cross-sections, collapse animations). Each candidate gets a **before/after visualisation**. Be visual.

For each candidate, render a card with:

- **Files**: which files/modules are involved
- **Problem**: why the current architecture is causing friction, and which symptom it causes
- **Solution**: plain English description of what would change
- **Responsibility**: one sentence on what the deepened module does
- **Stays out**: related logic that stays outside the deepened module, and why
- **Wins**: explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram**: side-by-side, custom-drawn, illustrating the shallowness and the deepening
- **Recommendation strength**: one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge
- **Tackle later**: a self-contained prompt that takes this candidate into `/grill-with-docs` in a fresh session, for the candidates the user doesn't pick now

**Deep is not big.** A deepening gathers one concept that is scattered across modules. Modules that are only called together are not one concept, so keep them apart. If the Responsibility sentence needs "and" more than once, split the candidate or drop it.

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**Use GLOSSARY.md vocabulary for the domain, and the `codebase-design` vocabulary for the architecture.** If `GLOSSARY.md` defines "Order," talk about "the Order intake module," not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly in the card (e.g. a warning callout: _"contradicts ADR-0007, but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?" (if your harness has a multiple-choice question tool, such as `AskUserQuestion` in Claude Code, ask through it with one option per candidate).

### 4. Grilling loop

Once the user picks a candidate, call the Skill tool with "grilling" to walk the decision tree with them: constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline as decisions crystallize; call the Skill tool with "domain-modeling" to keep the domain model current as you go:

- **Naming a deepened module after a concept not in `GLOSSARY.md`?** Add the term to `GLOSSARY.md`. Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `GLOSSARY.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing; skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **Want to explore alternative interfaces for the deepened module?** Call the Skill tool with "codebase-design" and use its design-it-twice parallel sub-agent pattern.

### 5. Hand off to the build

The grilling ends when the shape of the deepened module is settled: its interface, what sits behind the seam, and which tests survive. Stay in this session, since the build needs the grilling as it happened, and tell the user the next step:

- **The refactor takes more than one session**: `/to-spec`, then `/to-tickets`, then `/implement` per ticket (`$to-spec`, `$to-tickets`, `$implement` in Codex).
- **It fits in this session**: `/implement` right here (`$implement` in Codex).

To tackle another candidate later, the user pastes its **Tackle later** prompt from the report into a fresh session.
