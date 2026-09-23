---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, says "grill me", or asks to poke holes in, challenge, or be interviewed about a plan or design, even without the word "grill".
license: MIT
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask at most four frontier questions in one round, starting with the ones whose answers remove the most other questions: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Every question offers the smallest option first: do nothing, reuse what exists, or defer. Recommend it unless you can name a concrete case the user will hit where it fails. When you recommend more, name what it adds (a field, a state, a command, a file, a concept) and what breaks without it.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

When every question in a round has a short set of options, and your harness has a multiple-choice question tool (such as `AskUserQuestion` in Claude Code), ask the round through it instead, with the recommended option first.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

Ask only questions whose answer changes what gets built or what the user sees. A detail the implementer can settle alone is not a question, so it never joins the tree. The session is done when the frontier is empty: every decision that changes what gets built is settled. Do not act on it until the user confirms you have reached a shared understanding.
