#!/bin/sh
# Tests skills/tdd/scripts/mutate.sh against a one-line program and its test.
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

cd "$TMP"
printf '# sum\n\techo $((1+1))\n' > add.sh
cp add.sh add.orig
printf 'add.sh\n1+1\n====\n1+2\n' > red.m
printf 'add.sh\n# sum\n====\n# total\n' > green.m
printf 'add.sh\n$((1+1))\n====\n$((1+\n' > broken.m
printf 'add.sh\n2+2\n====\n3+3\n' > missing.m
printf 'add.sh\n# sum\n\techo\n====\n# sum\n\techo 3; exit\n' > multiline.m

if out="$(sh "$REPO/skills/tdd/scripts/mutate.sh" -b 'sh -n add.sh' '[ "$(sh add.sh)" = 2 ]' \
  red.m green.m broken.m missing.m multiline.m)"; then
  fail "mutate.sh exited zero with mutations that were not red"
fi
[ "$out" = "red.m red
green.m GREEN
broken.m broken
missing.m missing
multiline.m red" ] || fail "unexpected report: $out"
cmp -s add.sh add.orig || fail "add.sh was not restored"

sh "$REPO/skills/tdd/scripts/mutate.sh" '[ "$(sh add.sh)" = 2 ]' red.m >/dev/null || fail "an all-red run exited nonzero"

# A broken mutation, as a deleted name is in Go, gets a hint on stderr to keep
# the name in use. A run with none broken prints no hint.
hint="$(sh "$REPO/skills/tdd/scripts/mutate.sh" -b 'sh -n add.sh' '[ "$(sh add.sh)" = 2 ]' broken.m 2>&1 >/dev/null)" || true
case "$hint" in
*"false && cond"*) ;;
*) fail "a broken mutation printed no hint: $hint" ;;
esac
hint="$(sh "$REPO/skills/tdd/scripts/mutate.sh" -b 'sh -n add.sh' '[ "$(sh add.sh)" = 2 ]' red.m 2>&1 >/dev/null)"
[ -z "$hint" ] || fail "a run with no broken mutation printed: $hint"

# A TEST already red with no mutation, as `-run A|B` is once sh reads the | as
# a pipe, would report every mutation red. The run stops before any.
code=0
out="$(sh "$REPO/skills/tdd/scripts/mutate.sh" '[ "$(sh add.sh)" = 2 ] | no-such-command' red.m 2>&1)" || code=$?
[ "$code" = 2 ] || fail "a red baseline exited $code, want 2"
case "$out" in
*"fails with no mutation"*) ;;
*) fail "a red baseline reported: $out" ;;
esac
cmp -s add.sh add.orig || fail "add.sh changed on a red baseline"

code=0
sh "$REPO/skills/tdd/scripts/mutate.sh" -b false '[ "$(sh add.sh)" = 2 ]' red.m >/dev/null 2>&1 || code=$?
[ "$code" = 2 ] || fail "a broken baseline BUILD exited $code, want 2"

echo "ok"
