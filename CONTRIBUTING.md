# Contributing

Bug reports, skill ideas, and pull requests are welcome. For a new skill or a large change, open an issue first so we can agree on the shape before you write it.

## Set up

Fork the repository and clone your fork. Install [lefthook](https://lefthook.dev) and [betterleaks](https://github.com/betterleaks/betterleaks), then turn on the git hooks. They scan commits for secrets and dashes, check commit messages, and run the tests before a push:

```
brew install lefthook betterleaks
lefthook install
```

To try your working copy in Claude Code, start a session with the plugin loaded from disk:

```
claude --plugin-dir .
```

In Codex, add your clone as a marketplace and install from it:

```
codex plugin marketplace add .
codex plugin add supermatt@supermatt
```

## Check your change

Run these checks before you open a pull request. CI runs them too:

```
claude plugin validate --strict .
claude plugin validate --strict ./skills
sh tests/link-skills.test.sh
sh tests/mutate.test.sh
sh tests/release.test.sh
sh tests/directory-branch.test.sh
node --test tests/
```

`node --test tests/` runs `tests/next-issue.test.mjs`, which tests the `orchestrate` skill's issue picker; `bun test tests/` runs the same file, and the pre-push hook uses it. `tests/link-skills.test.sh` tests `scripts/link-skills.sh` and syntax-checks the shell templates in `skills/`. `tests/mutate.test.sh` tests the `tdd` skill's mutation runner. `tests/release.test.sh` and `tests/directory-branch.test.sh` test the maintainer's `scripts/release.sh` and `scripts/directory-branch.sh`. Skill behavior has no automated tests yet, so describe in the pull request how you ran the changed skill and what it did.

## Rules for a change

[AGENTS.md](./AGENTS.md) states what an acceptable change must satisfy. Read it before you edit a skill. It covers the skill layout, the README entry, the `ask-supermatt` router, the version bump, the `CHANGELOG.md` entry, and the ban on em dashes.

## Open a pull request

1. Create a branch named `type/kebab-description`, such as `fix/tdd-red-check`.
2. Write commits as Conventional Commits: `type(scope): description`.
3. Open the pull request against `main` and fill in the template.

Pull requests are squash merged.

## Who decides

Leonid Svyatov maintains SuperMatt and is the only person who merges and releases. No successor is arranged.
