# Linear queue

Use the configured Linear MCP for issue operations and `gh` for GitHub PRs and CI. Resolve the dedicated project and default team from the repository tracker configuration. Keep full team-prefixed identifiers throughout the run. The default team is a creation default. Every team in the project contributes work.

## Read the queue

Repeat these reads on each Pick. Never reuse a previous snapshot after an issue changes.

1. List issues by project ID with no team filter. Follow every page. Include unassigned, unarchived candidates in active workflow types (`triage`, `backlog`, `unstarted`, `started`). Read the identifier, project ID, title, team, label names, assignee ID and workflow state type. When the MCP returns a state name, resolve it from that issue's team states.
2. For each candidate, follow the tracker's **Resolve blockers** operation for incoming native relations and explicit `Blocked by:` declarations. Read explicitly referenced external blockers only for their states. Use the configured **List children** operation, including archived children and every page. Hold a parent with unresolved child membership. For a parent, set `implementationSpec: true` only when its body identifies an implementation spec or its implementation tickets explicitly name it in their `## Parent` section. A native child link alone does not identify a spec. Leave Wayfinder maps and decision tickets to Wayfinder. Record one state type per blocker or child. Only `completed` satisfies either relation. Record a malformed, unreadable or unknown target as `null` and report its reference as a blocker. If a project page, relation list, or child list cannot be read completely, stop selection and report that failure.
3. Pass a JSON array on stdin to `RUN <skill directory>/scripts/next-issue.mjs --linear PROJECT_ID READY BUG TRIAGE`. Each row has this shape:

   ```json
   {"id":"ENG-42","projectId":"project-uuid","title":"Repair search","statusType":"started","assigneeId":null,"labels":["bug","ready-for-agent"],"blockerStates":["completed"],"childStates":[]}
   ```

   Use the issue identifier for `id`. Empty arrays require confirmed empty lists. Supply data through a structured file write or stdin, keeping issue text out of shell commands. If using a temporary snapshot, keep it outside the repository and delete it after selection. The selector needs no Linear credentials. It prints the same three columns as the other trackers and uses the complete identifier as the key. For a selected item, retain its project ID, team, URL, and labels for branch selection and worker dispatch.

## Worker access and completion

Pass the configured project, default team, assigned issue's actual team, REF and URL on every dispatch. Read and update the assigned issue through the worker's connected MCP. If the worker lacks a required capability, park with the operation and REF. Keep the full identifier in commit and PR evidence. For shipping, pass REF to the worker as an explicit resolution target, and distinguish any contextual links to parents and blockers.

Use the repository's tracker operations for native comments, triage labels, child creation and closure. Recheck project membership before writes. Each lane owns its assigned issue. New gap tickets use the configured project and native parent; follow the configured team selection. A change affecting another lane or an external issue is outside the lane's scope.

After the ship slot's merge and post-merge checks succeed, independently re-read every explicitly resolved Linear issue from the shipping record. Confirm project membership and state type. Leave completed issues alone. For outstanding targets, use the tracker Close operation with the merged PR URL and re-read each target to verify its completed state. A merge alone does not release dependents. Park with the missing reference or evidence if the assigned issue is absent from the resolution record or completion cannot be verified.
