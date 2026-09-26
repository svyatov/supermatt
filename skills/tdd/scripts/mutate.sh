#!/bin/sh
# Usage: mutate.sh [-b BUILD] TEST MUTATION...
#
# Applies each mutation on its own, runs BUILD (when given) and then TEST, and
# restores the file before the next one. A mutation file holds the target path
# on its first line, then the exact text to find, a line holding only ====, and
# the text to put in its place. Only the first match is replaced.
#
# Prints one line per mutation file: red (TEST failed), GREEN (TEST passed: no
# test protects that behavior), broken (BUILD failed, which proves nothing),
# or missing (the text to find is not in the file). Exits 1 unless every
# mutation is red. Exits 2 before any mutation when BUILD or TEST already
# fails on the unchanged code, since every mutation would then read red. After
# a broken mutation, a hint on stderr names its usual cause, an unused name.
set -u

build=
if [ "${1-}" = -b ]; then
  build=$2
  shift 2
fi
if [ $# -lt 2 ]; then
  echo "usage: mutate.sh [-b BUILD] TEST MUTATION..." >&2
  exit 2
fi
test=$1
shift

if ! { [ -z "$build" ] || sh -c "$build"; } > /dev/null 2>&1 || ! sh -c "$test" > /dev/null 2>&1; then
  echo "mutate.sh: BUILD or TEST fails with no mutation applied, so no red would mean anything: $test" >&2
  exit 2
fi

backup=$(mktemp)
target=
trap 'if [ -n "$target" ]; then cp "$backup" "$target"; fi; rm -f "$backup"' EXIT
trap 'exit 130' INT TERM

status=0
for m in "$@"; do
  target=$(head -n 1 "$m")
  cp "$target" "$backup"
  if ! awk '
    FNR == NR {
      if (FNR == 1) next
      if ($0 == "====" && !sep) { sep = 1; next }
      if (sep) to = (tn++ ? to "\n" : "") $0
      else from = (fn++ ? from "\n" : "") $0
      next
    }
    { text = (n++ ? text "\n" : "") $0 }
    END {
      i = index(text, from)
      if (from == "" || !i) exit 3
      printf "%s%s%s\n", substr(text, 1, i - 1), to, substr(text, i + length(from))
    }' "$m" "$backup" > "$target"; then
    result=missing
  elif [ -n "$build" ] && ! sh -c "$build" > /dev/null 2>&1; then
    result=broken
  elif sh -c "$test" > /dev/null 2>&1; then
    result=GREEN
  else
    result=red
  fi
  cp "$backup" "$target"
  target=
  echo "$m $result"
  [ "$result" = red ] || status=1
  [ "$result" = broken ] && broken=1
done
if [ -n "${broken-}" ]; then
  echo "mutate.sh: a broken mutation proves nothing. When the build rejects a name the mutation left unused, keep it in use: false && cond in place of a deleted cond." >&2
fi
exit $status
