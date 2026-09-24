#!/bin/sh
# Tests scripts/release.sh -n against a temporary repository and its origin.
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

git init -q --bare -b main "$TMP/origin.git"
git clone -q "$TMP/origin.git" "$TMP/work" 2>/dev/null
cd "$TMP/work"
git config user.name test
git config user.email test@example.com
git config commit.gpgsign false
git config tag.gpgsign false
mkdir scripts .claude-plugin
cp "$REPO/scripts/release.sh" scripts/
printf '{\n  "name": "x",\n  "version": "1.2.0"\n}\n' > .claude-plugin/plugin.json
printf '# Changelog\n\n## [Unreleased]\n\n## [1.2.0] - 2026-01-02\n\n### Fixed\n\n- a fix.\n\n## [1.1.0] - 2026-01-01\n\n- old.\n' > CHANGELOG.md
git add -A && git commit -q -m init && git push -q origin main

out="$(sh scripts/release.sh -n)" || fail "dry run exited nonzero"
[ "$out" = "v1.2.0

### Fixed

- a fix." ] || fail "unexpected dry run output: $out"

echo dirty >> CHANGELOG.md
sh scripts/release.sh -n >/dev/null 2>&1 && fail "accepted a dirty working tree"
git checkout -q CHANGELOG.md

git commit -q --allow-empty -m ahead
sh scripts/release.sh -n >/dev/null 2>&1 && fail "accepted main ahead of origin/main"
git push -q origin main

git tag v1.2.0
sh scripts/release.sh -n >/dev/null 2>&1 && fail "accepted a version whose tag exists"
git tag -d v1.2.0 >/dev/null

sed 's/1\.2\.0/1.3.0/' .claude-plugin/plugin.json >| plugin.tmp && mv plugin.tmp .claude-plugin/plugin.json
git commit -q -am bump && git push -q origin main
sh scripts/release.sh -n >/dev/null 2>&1 && fail "accepted a version with no CHANGELOG section"

echo "ok"
