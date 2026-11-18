# Issue tracker: Linear

Issues, specs, and Wayfinder maps live in one dedicated Linear project. GitHub hosts pull requests, reviews, merges, and CI.

| Setting | Value |
| --- | --- |
| Linear workspace | <workspace name and ID> |
| Dedicated project | <project name and ID> |
| Default creation team | <team key and ID> |
| GitHub PR repository | <owner/repo> |
| Status choices by team | <team-specific status IDs where ambiguous, or none> |

Use the connected Linear MCP server. Discover the host's available tools and argument schemas. The operations below use the official tool names without host prefixes. Older versions can expose separate create and update tools. Use an equivalent operation only when its schema supports the required behavior. If access, permissions, or required fields are unavailable, report the affected operation. Keep unverified work pending. Never switch issue trackers implicitly.

## Conventions

- **Scope and identity**: Resolve issue keys such as `ENG-123`, Linear issue URLs, or UUIDs with `get_issue(id)`. For a URL, extract its issue key or ID. Verify the workspace and returned `projectId` before acting. Use returned keys and URLs in human-facing references. Keep opaque UUIDs for joins and writes requiring IDs. A bare GitHub `#123` does not identify a Linear issue.
- **Create an issue**: Call `save_issue(team, project, title, description)` with the configured IDs. Use the default team unless an in-project team was explicitly selected. Include mapped labels, native parent, and relations as applicable. Verify the returned issue, project, and team. After an uncertain write, locate the original before retrying.
- **Read an issue**: Request `uuid`, `url`, `title`, `description`, `status`, `statusType`, `archivedAt`, `labels`, `projectId`, `teamId`, `parentId`, `assigneeId`, `createdBy`, `createdAt`, `updatedAt`, and `relations` through `get_issue(id, fields)`. With an older schema, use its full issue read with `includeRelations: true`. Fetch all `list_comments(issueId)` pages, including replies, authors, and timestamps.
- **List issues**: Call `list_issues(project: <project ID>)` across every project team. Never narrow the queue to the creation team. Follow each returned cursor while `hasNextPage` is true, including on label, child, and comment listings. Use the full issue and comment reads for triage. Report failed or truncated pages as incomplete.
- **Open issues**: Include non-archived issues in active workflow types (`triage`, `backlog`, `unstarted`, `started`). Use `list_issue_statuses(team)` to resolve a status to its type when necessary. Exclude `completed` and `canceled` from open queues. An unknown type leaves eligibility unverified.
- **Comment or update**: Use `save_comment(issueId, body)` to add a top-level comment. Edit an issue with `save_issue(id, ...)`. Preserve unrelated content when editing descriptions. Re-read after uncertain writes before retrying, including comments.
- **Apply / remove labels**: Resolve role names from `docs/agents/triage-labels.md` against active workspace or issue-team labels with `list_issue_labels`. Use unambiguous applicable label IDs in `addLabels` and `removeLabels`. Preserve unrelated labels, including during state transitions. Where only replacement is supported, read the complete current set, apply the delta, and verify. Use `save_issue_label(name, teamId)` for a missing team label when creation is authorized. Use workspace scope only for an intended shared label. All seven triage roles are labels. The five state labels are independent of Linear workflow status.
- **Close**: Add the requested reason as a comment. For declined, duplicate, out-of-scope, or `wontfix` work, use a team status of type `canceled`. For completed work, use type `completed`. Resolve the status ID with `list_issue_statuses(team)`, using the configured choice when ambiguous. If ambiguity remains, ask. Use `save_issue(id, state: <status ID>)` and verify the resulting type.

## When a skill says "publish to the issue tracker"

Create a Linear issue in the configured project. Return its Linear key and URL.

## When a skill says "fetch the issue"

Use **Read an issue**. Preserve the team's workflow type, mapped labels, parent, and native dependency metadata.

## Resolving implementation blockers

- **List children**: Page `list_issues(project: <project ID>, parentId: <parent ID>)`. Match the native parent and project by ID. Read open children, their labels, and all applicable blockers. A body mention alone does not establish parentage.
- **Attach a spec ticket**: Pass `parentId` on creation. When resuming, read the existing child. If already attached, reuse it. If unparented, call `save_issue(id, parentId)` and verify. Report a different parent without reparenting. Keep the spec's Linear link in the child's parent section.
- **Blocking**: After both issues exist, add the blocker using `save_issue(id: <dependent>, blockedBy: [<blocker>])`. Re-read the dependent's relations and verify the incoming edge. Preserve unrelated edges. Keep writes within the configured project. Read explicitly referenced cross-project blockers without modifying them.
- **Resolve blockers**: Read all incoming `blockedBy` relations, not outgoing `blocks`, related issues, or the parent. Resolve every explicit reference in any top-level `Blocked by:` declaration too. Fetch each blocker's current status type, including for explicitly referenced issues outside the project. Only `completed` satisfies a dependency. Active, canceled, unknown, malformed, or unreadable dependencies block eligibility. Missing or incomplete native relation data is unknown. Only a complete read with no incoming edges and no textual blockers establishes zero blockers.

## Wayfinding operations

- **Map and child ticket**: Create the map as an issue labelled `wayfinder:map`. Create native children with the appropriate `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling`, or `wayfinder:task` label. Wire dependencies in a second pass with **Blocking**.
- **Frontier query**: Use **List children** and **Resolve blockers**. Keep open, unblocked children without an assignee or an unreleased claim. Read all comment pages before granting work. Use map order when specified, otherwise creation order with the issue key as a tie-breaker.
- **Claim**: Only Wayfinder's single coordinator may grant a ticket. Recheck eligibility, append `Claimed by: <worker-session-id>`, then assign the driving developer with `save_issue(id, assignee)`. Read back the comment and assignment before granting the named worker permission to start. An unreleased claim reserves the ticket even after a failed assignment.
- **Release**: Once the prior worker has stopped, confirm ownership, clear the assignee with `save_issue(id, assignee: null)`, and append `Claim released: <worker-session-id>`. Verify both writes. Pair claims with later releases by session ID.
- **Resolve**: Comment with the answer, complete the ticket, and verify its status. Append the decision and ticket link to the map's Decisions so far. For an out-of-scope decision, use **Close** and update Out of scope.

## Pull requests as a triage surface

**PRs as a request surface: no.** Set to `yes` to include external GitHub PRs in triage. Work directly on each PR without creating a Linear issue.

With the flag enabled, list all pages of `gh api --paginate --slurp 'repos/{owner}/{repo}/pulls?state=open&per_page=100'` for the configured GitHub repository. Keep external authors with association `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE`. Read the PR's title, body, state, author, creation time, and labels with `gh pr view`. Read every discussion page via `gh api --paginate 'repos/{owner}/{repo}/issues/<number>/comments'`. Fetch the diff with `gh pr diff` when triaging that PR. Report incomplete reads before classification. Use the mapped label names on GitHub with `gh pr edit`. Comment or close there with `gh pr comment` or `gh pr close`.

## Shipping

List explicitly resolved Linear issue keys or links in the GitHub PR. A mention, parent link, or GitHub closing keyword alone proves no Linear transition. After the shipping skill verifies the merge and required checks, read each explicitly resolved in-project issue. Record issues already `completed`. Complete any outstanding ones through their own team's completed state and re-read them. Report the verified keys and any pending transition separately.
