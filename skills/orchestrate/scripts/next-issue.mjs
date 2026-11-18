#!/usr/bin/env node
// Prints open, unassigned work as "key<TAB>title<TAB>spec|ready|triage",
// specs first, then bugs, then lowest number first. An issue qualifies at one stage:
// - spec: a parent spec (it has sub-issues, or another issue's "## Parent" section names it)
//   whose children are all closed, so it is due for verification.
// - ready: it has the READY label.
// - triage: a BUG with the TRIAGE label.
// On GitHub, specs and triage bugs qualify only when filed by the repo's owner,
// a member, or a collaborator. Each tracker supplies its own dependency evidence.
// Usage: next-issue.mjs [--local ROOT | --linear PROJECT_ID] READY BUG TRIAGE
import { execFileSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const TEAM = ["OWNER", "MEMBER", "COLLABORATOR"];

const key = (issue) => issue.linearIdentifier ?? issue.localPath ?? issue.number;
const parents = (issue) => issue.parents ?? [...(issue.body ?? "").matchAll(/## Parent\s+#(\d+)/g)].map((m) => Number(m[1]));

const blockers = (issue) =>
  issue.blockers ?? (issue.body ?? "").split("\n").filter((l) => l.startsWith("Blocked by:")).flatMap((l) => [...l.matchAll(/#(\d+)/g)].map((m) => Number(m[1])));

export function pick(issues, ready, bug, triage) {
  issues = issues.filter((i) => !("pull_request" in i));
  const open = new Set(issues.filter((i) => i.state === "open").map(key));
  const children = new Map();
  for (const i of issues) for (const p of parents(i)) children.set(p, [...(children.get(p) ?? []), i]);
  const labelled = (i, name) => i.labels.some((l) => l.name === name);

  const stageOf = (i) => {
    const team = Boolean(i.linearIdentifier) || TEAM.includes(i.author_association);
    const subs = i.sub_issues_summary ?? {};
    if ((subs.total ?? 0) > 0 || children.has(key(i))) {
      const done = (subs.completed ?? 0) === (subs.total ?? 0) && !(children.get(key(i)) ?? []).some((c) => c.state === "open");
      return done && team ? "spec" : null;
    }
    if (labelled(i, ready)) return "ready";
    if (labelled(i, bug) && labelled(i, triage) && team) return "triage";
    return null;
  };
  const rank = (i) => (i.stage === "spec" ? 0 : labelled(i, bug) ? 1 : 2);

  return issues
    .map((i) => ({ ...i, stage: stageOf(i) }))
    .filter((i) =>
      i.stage && i.state === "open" &&
      i.assignees.length === 0 &&
      !(i.issue_dependencies_summary?.blocked_by > 0) &&
      !blockers(i).some((n) => open.has(n)))
    .sort((a, b) => rank(a) - rank(b) || a.number - b.number || String(key(a)).localeCompare(String(key(b))));
}

// Local ticket numbers belong to their feature directory, not the whole repo.
export function loadLocal(root, cwd = process.cwd()) {
  root = resolve(root);
  const issues = [];
  const read = (path, number, parents = []) => {
    const body = readFileSync(path, "utf8");
    const metadata = body.split(/^##\s/m)[0];
    const field = (name) => metadata.match(new RegExp(`^${name}:[ \\t]*(.*)$`, "m"))?.[1].trim() ?? "";
    const status = field("Status");
    return { localPath: relative(cwd, path), number, body, parents,
      title: (body.match(/^#\s+(.+)/m)?.[1] ?? relative(root, path)).replace(/^\d+:\s*/, "").trim(),
      state: field("Closed") || status === "closed" ? "closed" : "open",
      labels: [status, field("Category")].filter(Boolean).map(name => ({ name })),
      assignees: field("Assignee") ? [field("Assignee")] : [], author_association: "OWNER",
      blockedBy: field("Blocked by"), blockers: [],
    };
  };
  for (const feature of readdirSync(root, { withFileTypes: true }).filter(entry => entry.isDirectory())) {
    const directory = join(root, feature.name), ticketDirectory = join(directory, "issues");
    if (!existsSync(ticketDirectory)) continue;
    const specPath = join(directory, "spec.md");
    const spec = existsSync(specPath) ? read(specPath, 0) : null;
    const tickets = new Map();
    for (const entry of readdirSync(ticketDirectory, { withFileTypes: true })) {
      const match = entry.name.match(/^(\d+)-.+\.md$/);
      if (!entry.isFile() || !match) continue;
      const number = Number(match[1]);
      if (tickets.has(number)) throw new Error(`Duplicate ticket ${number} in ${ticketDirectory}`);
      tickets.set(number, read(join(ticketDirectory, entry.name), number, spec ? [spec.localPath] : []));
    }
    for (const ticket of tickets.values()) {
      if (ticket.blockedBy) {
        if (!/^\d+(?:\s*,\s*\d+)*$/.test(ticket.blockedBy)) throw new Error(`Invalid blocker list in ${ticket.localPath}`);
        ticket.blockers = ticket.blockedBy.split(",").map(value => {
          const blocker = tickets.get(Number(value.trim()));
          if (!blocker) throw new Error(`Missing blocker ${value.trim()} in ${ticket.localPath}`);
          return blocker.localPath;
        });
      }
      issues.push(ticket);
    }
    if (spec && tickets.size) issues.push(spec);
  }
  return issues;
}

// The host resolves relations through its connected MCP and streams the snapshot on stdin.
function loadLinear(projectId) {
  const rows = JSON.parse(readFileSync(0, "utf8"));
  if (!Array.isArray(rows)) throw new Error("Invalid Linear snapshot: expected an array");
  const issues = [];
  const seen = new Set();
  for (const row of rows) {
    if (!row || typeof row.projectId !== "string" || !row.projectId) throw new Error("Invalid Linear project ID");
    if (row.projectId !== projectId) continue;
    const number = typeof row.id === "string" && row.id.match(/^[A-Z0-9][A-Z0-9_-]*-(\d+)$/i);
    if (!number || seen.has(row.id) || typeof row.title !== "string" || typeof row.statusType !== "string" ||
        !(row.assigneeId === null || typeof row.assigneeId === "string" && row.assigneeId.length) ||
        !Array.isArray(row.labels) || !row.labels.every(label => typeof label === "string") ||
        !Array.isArray(row.blockerStates) || !Array.isArray(row.childStates)) {
      throw new Error(`Invalid Linear issue snapshot: ${row.id ?? "(missing identifier)"}`);
    }
    seen.add(row.id);
    if (!["triage", "backlog", "unstarted", "started"].includes(row.statusType)) continue;
    issues.push({
      linearIdentifier: row.id, number: Number(number[1]), title: row.title, state: "open",
      labels: row.labels.map(name => ({ name })), assignees: row.assigneeId ? [row.assigneeId] : [],
      issue_dependencies_summary: { blocked_by: row.blockerStates.filter(state => state !== "completed").length },
      sub_issues_summary: { total: row.childStates.length, completed: row.childStates.filter(state => state === "completed").length },
    });
  }
  return issues;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2);
  const mode = ["--local", "--linear"].includes(args[0]) ? args.shift() : null;
  const scope = mode ? args.shift() : null;
  if (args.length !== 3 || (mode && !scope?.trim())) {
    console.error("usage: next-issue.mjs [--local ROOT | --linear PROJECT_ID] READY BUG TRIAGE");
    process.exit(1);
  }
  try {
    let issues;
    if (mode === "--linear") issues = loadLinear(scope);
    else if (mode === "--local") issues = loadLocal(scope);
    else issues = JSON.parse(execFileSync("gh", ["api", "repos/{owner}/{repo}/issues?state=all&per_page=100", "--paginate", "--slurp"], { encoding: "utf8", maxBuffer: 256 * 1024 * 1024 })).flat();
    for (const i of pick(issues, ...args)) console.log(`${key(i)}\t${i.title.replace(/[\t\r\n]/g, " ")}\t${i.stage}`);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}
