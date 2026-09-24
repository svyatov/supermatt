#!/bin/sh
# Usage: release.sh [-n]
#
# Tags and publishes the version in .claude-plugin/plugin.json. Run it on main
# after the release pull request merges. It creates a signed tag, pushes it, and
# opens a GitHub Release whose notes are that version's CHANGELOG.md section.
# -n prints the tag and the notes, then stops before tagging.
set -eu

die() { echo "release.sh: $*" >&2; exit 1; }

cd "$(dirname "$0")/.."
version=$(sed -n 's/^ *"version": *"\([^"]*\)".*/\1/p' .claude-plugin/plugin.json)
tag="v$version"

[ -z "$(git status --porcelain)" ] || die "the working tree has changes"
git fetch -q origin main --tags
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || die "HEAD is not origin/main"
if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then die "$tag already exists"; fi

notes=$(awk -v h="## [$version]" '
  /^## \[/ { on = index($0, h) == 1; next }
  on && (seen || NF) { seen = 1; print }' CHANGELOG.md)
[ -n "$notes" ] || die "CHANGELOG.md has no section for $version"

if [ "${1-}" = -n ]; then
  printf '%s\n\n%s\n' "$tag" "$notes"
  exit
fi

git tag -s -m "$tag" "$tag"
git push origin "$tag"
printf '%s\n' "$notes" | gh release create "$tag" --verify-tag --title "$tag" --notes-file -
