# Privacy policy

SuperMatt is a set of agent skills: Markdown instructions and a few shell scripts that run inside your agent (Claude Code, Codex, or a Claude app). It has no server, no account, and no telemetry. The maintainer receives no data from it, and SuperMatt itself stores nothing outside the files it writes in your working directory.

## Where your data goes

Your agent handles your conversation and code under the terms of its own provider. Beyond that, some skills pass data to tools and services you set up yourself:

- **`code-review`** hands its Adversarial axis to a second model: the `codex` CLI (OpenAI) when Claude Code runs the review, or the `claude` CLI (Anthropic) when Codex runs it. That model receives the diff under review and the review instructions, and can read the repository without changing it. The axis skips this step when that CLI isn't installed.
- **`to-spec`, `to-tickets`, `triage`, `wayfinder`, `implement`, and `code-review`** read or write issues on the issue tracker you choose in `setup-supermatt-skills`: GitHub through the `gh` CLI, GitLab through the `glab` CLI, or local Markdown files.
- **`research`** reads public web pages and documentation to answer your question.
- **`architecture-review`** writes an HTML report that loads Tailwind and Mermaid from `cdn.jsdelivr.net` when you open it in a browser.

Each of those services handles the data under its own privacy policy.

## What SuperMatt writes locally

Skills write files into your working directory when you use them: specs, tickets in a local tracker, `GLOSSARY.md`, ADRs, handoff documents, research notes, reports, and prototypes. They stay on your machine unless you commit and push them.

## Contact

Ask about this policy in [GitHub issues](https://github.com/svyatov/supermatt/issues). For a security problem, follow [SECURITY.md](./SECURITY.md).
