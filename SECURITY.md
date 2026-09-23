# Security policy

## Report a vulnerability

Report it privately through [GitHub private vulnerability reporting](https://github.com/svyatov/supermatt/security/advisories/new). Do not open a public issue.

You get a first response within 7 days.

## What to report

- A skill that leads an agent to run a destructive or data-leaking command the user did not ask for.
- A bundled script or template that is unsafe to run, such as the `wizard` template or `scripts/link-skills.sh`.
- Skill text that lets untrusted input, such as an issue body or a fetched web page, take over the agent.

## Supported versions

Only the latest release gets fixes. The version is in `.claude-plugin/plugin.json`.
