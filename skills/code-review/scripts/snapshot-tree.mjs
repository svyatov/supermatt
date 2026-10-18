#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { closeSync, constants, fstatSync, lstatSync, openSync, readFileSync, readlinkSync, realpathSync } from "node:fs";

try {
  if (process.argv.length !== 3) throw new Error("Usage: snapshot-tree.mjs <repository-root>");
  process.chdir(realpathSync(process.argv[2]));
  const git = (...args) => execFileSync("git", [
    "--no-pager", "--no-optional-locks", "-c", "core.fsmonitor=false", ...args,
  ], { maxBuffer: Infinity, stdio: ["ignore", "pipe", "pipe"] });
  if (git("rev-parse", "--show-prefix").toString().trim()) {
    throw new Error("Run the snapshot from the repository root");
  }

  const status = git("status", "--porcelain=v1", "-z", "--untracked-files=all").toString("base64");
  const diff = git("diff", "--no-ext-diff", "--no-textconv", "--binary", "--full-index", "HEAD").toString("base64");
  const staged = git("diff", "--cached", "--no-ext-diff", "--no-textconv", "--binary", "--full-index", "HEAD").toString("base64");
  const listed = git("ls-files", "-z", "--others", "--exclude-standard");
  const paths = [];
  let start = 0;
  for (let end = 0; end < listed.length; end++) {
    if (listed[end] !== 0) continue;
    paths.push(listed.subarray(start, end));
    start = end + 1;
  }
  paths.sort(Buffer.compare);

  const untracked = paths.map(path => {
    // Check parents as well as the leaf: a symlink must never turn into a content read.
    for (let slash = path.indexOf(47); slash !== -1; slash = path.indexOf(47, slash + 1)) {
      if (!lstatSync(path.subarray(0, slash)).isDirectory()) {
        throw new Error(`Non-directory parent of ${path.toString("base64")}`);
      }
    }
    const stat = lstatSync(path);
    const entry = { path: path.toString("base64"), mode: stat.mode & 0o777 };
    if (stat.isSymbolicLink()) {
      return { ...entry, type: "symlink", target: readlinkSync(path, { encoding: "buffer" }).toString("base64") };
    }
    if (!stat.isFile()) throw new Error(`Unsupported untracked file type: ${entry.path}`);
    const fd = openSync(path, constants.O_RDONLY | constants.O_NOFOLLOW | constants.O_NONBLOCK);
    try {
      if (!fstatSync(fd).isFile()) throw new Error(`Untracked path changed type: ${entry.path}`);
      return { ...entry, type: "file", sha256: createHash("sha256").update(readFileSync(fd)).digest("hex") };
    } finally {
      closeSync(fd);
    }
  });
  process.stdout.write(JSON.stringify({ status, diff, staged, untracked }) + "\n");
} catch (error) {
  console.error(`Working-tree snapshot failed: ${error.message}`);
  process.exitCode = 1;
}
