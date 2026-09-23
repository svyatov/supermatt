Each skill is a directory directly under `skills/` (`skills/<name>/SKILL.md`), never nested deeper: Codex rejects nested skills. The plugin ships every skill in `skills/`.

Every skill must have an entry in the top-level `README.md`, under **Engineering** (daily code work) or **Productivity** (daily non-code workflow tools), that links the skill name to its `SKILL.md`. Each section groups its entries into **User-invoked** and **Model-invoked**.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](./.agents/invocation.md).

[`ask-matt`](./skills/ask-matt/SKILL.md) is the router that maps every user-reachable skill and how they relate. The same trigger that re-syncs a docs page applies to it: whenever you add, rename, remove, or change how a user-reachable skill fits the flows, re-read `ask-matt`'s `SKILL.md` and update it so the map stays accurate: a new skill it never mentions, or a stale one it still routes to, is a router that lies.

Any change to a shipped skill must bump `version` in `.claude-plugin/plugin.json` (semver: PATCH for fixes, MINOR for new skills or features, MAJOR for removals or renames) and add a `CHANGELOG.md` entry. Plugin users get updates only on a version bump; commits without one never reach them. `plugin.json` holds the only `version`: the Claude Code catalog (`.claude-plugin/marketplace.json`) and the Codex catalog (`.agents/plugins/marketplace.json`) must not set one, and both must list the same plugins.

To (re)link every skill outside `deprecated/` and `misc/` into the local harness skill directories (`~/.claude/skills`, `~/.agents/skills`), run `scripts/link-skills.sh`. Each entry is a symlink into this repo, so a `git pull` keeps installed skills current; re-run the script after adding, removing, or renaming a skill.

No em-dashes anywhere in this repo's prose (`SKILL.md` files, docs, `README.md`, `CHANGELOG.md`, ADRs, changesets, code comments). Where a sentence reaches for one, rewrite it instead with a comma, colon, period, parentheses, or a conjunction, whichever the sentence actually wants; never do a blind character substitution.
