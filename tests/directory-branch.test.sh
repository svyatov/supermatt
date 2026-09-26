#!/bin/sh
# Tests scripts/directory-branch.sh against a temporary repository and its origin.
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
mkdir -p .claude-plugin skills/a scripts tests .github/workflows
for f in README.md .claude-plugin/plugin.json skills/a/SKILL.md scripts/s.sh tests/t.sh .github/workflows/ci.yml; do
  echo x > "$f"
done
git add -A && git commit -q -m init && git tag v1.0.0 && git push -q origin main v1.0.0

sh "$REPO/scripts/directory-branch.sh" v1.0.0 || fail "first run exited nonzero"
files="$(git --git-dir="$TMP/origin.git" ls-tree -r --name-only directory)"
[ "$files" = ".claude-plugin/plugin.json
README.md
skills/a/SKILL.md" ] || fail "unexpected directory tree: $files"
[ -z "$(git status --porcelain)" ] || fail "the working tree or index changed"

echo y > skills/a/SKILL.md
git commit -q -am change && git tag v1.1.0 && git push -q origin main v1.1.0
sh "$REPO/scripts/directory-branch.sh" v1.1.0 || fail "second run exited nonzero"
log="$(git --git-dir="$TMP/origin.git" log --format=%s directory)"
[ "$log" = "v1.1.0
v1.0.0" ] || fail "directory history is not one commit per release: $log"
[ "$(git --git-dir="$TMP/origin.git" show directory:skills/a/SKILL.md)" = y ] || fail "directory branch missed the release's change"

echo "ok"
