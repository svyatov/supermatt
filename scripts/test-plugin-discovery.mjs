#!/usr/bin/env node
import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { installPlugin, listSkills, manifest, privateEnvironment, project, run, save, snapshot, verifyDiscovery } from "./lib/skill-evidence.mjs";

const { values } = parseArgs({ options: { repo: { type: "string", default: "." }, revision: { type: "string", default: "working" }, codex: { type: "string", default: "codex" } } });
const evidence = mkdtempSync(join(tmpdir(), "supermatt-discovery-"));
const work = join(evidence, "work"); mkdirSync(work);
const report = { status: "blocked", packaging: "unobserved", discovery: "unobserved", execution: "unobserved", claude: "unavailable", modelCalls: 0 };
try {
  await snapshot(resolve(values.repo), values.revision, join(work, "source"));
  const carrier = join(work, "carrier"); project(join(work, "source"), carrier);
  const expected = manifest(carrier); save(join(evidence, "manifest.json"), expected);
  report.packaging = "pass";
  const env = privateEnvironment(join(work, "home"));
  const cwd = join(work, "project"); mkdirSync(cwd);
  const options = { env, cwd };
  report.cli = (await run(values.codex, ["--version"], options)).trim();
  await installPlugin(values.codex, carrier, options);
  const before = await listSkills(values.codex, options);
  save(join(evidence, "discovery-before.json"), before);
  verifyDiscovery(before, expected, env.CODEX_HOME);
  rmSync(carrier, { recursive: true }); rmSync(join(work, "source"), { recursive: true });
  const after = await listSkills(values.codex, options);
  save(join(evidence, "discovery-after.json"), after);
  report.verified = verifyDiscovery(after, expected, env.CODEX_HOME);
  report.discovery = "pass"; report.status = "pass";
} catch (error) { report.error = error.message; process.exitCode = 1; }
finally {
  save(join(evidence, "report.json"), report);
  // Only disposable execution state is removed. Reports survive both outcomes.
  rmSync(work, { recursive: true, force: true });
  console.log(JSON.stringify({ ...report, evidence }, null, 2));
}
