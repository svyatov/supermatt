#!/bin/sh
# Usage: mutate.sh [-b BUILD] [-t SECONDS] TEST MUTATION...
#
# Applies each mutation on its own, runs BUILD (when given) and then TEST, and
# restores the file before the next one. A mutation file holds the target path
# on its first line, then the exact text to find, a line holding only ====, and
# the text to put in its place. Only the first match is replaced.
#
# Prints one line per mutation file: red (TEST failed), GREEN (TEST passed: no
# test protects that behavior), timeout (TEST ran past SECONDS and was killed),
# broken (BUILD failed, which proves nothing), or missing (the text to find is
# not in the file). SECONDS defaults to five times the unchanged run plus a
# minute. Exits 1 unless every mutation is red. Exits 2 before any mutation
# when BUILD or TEST already fails on the unchanged code, since every mutation
# would then read red. After a broken mutation, a hint on stderr names its
# usual cause, an unused name.
#
# TEST runs in a process group of its own, killed whole once TEST exits. A
# process whose parent died, as a test runner's child does when the runner is
# killed on its own timeout, stays in the group, so nothing TEST started
# outlives it. perl creates the group, since dash has no job control without a
# terminal.
set -u

build= limit=
while [ $# -gt 0 ]; do
  case $1 in
  -b) build=$2; shift 2 ;;
  -t) limit=$2; shift 2 ;;
  *) break ;;
  esac
done
case $limit in
*[!0-9]*) set -- ;;
esac
if [ $# -lt 2 ]; then
  echo "usage: mutate.sh [-b BUILD] [-t SECONDS] TEST MUTATION..." >&2
  exit 2
fi
if ! command -v perl > /dev/null 2>&1; then
  echo "mutate.sh: perl is required, to run TEST in a process group of its own" >&2
  exit 2
fi
test=$1
shift

backup=$(mktemp)
target= group= timer=
trap 'stop; if [ -n "$target" ]; then cp "$backup" "$target"; fi; rm -f "$backup" "$backup.expired"' EXIT
trap 'exit 130' INT TERM

# stop kills TEST's process group and the timer's, where either runs.
stop() {
  for g in $group $timer; do
    kill -KILL -"$g" 2> /dev/null
    wait "$g" 2> /dev/null
  done
  group= timer=
}

# run_test runs TEST, killed at $limit seconds when limit is set, and sets
# outcome to pass, fail or timeout.
run_test() {
  rm -f "$backup.expired"
  perl -e 'setpgrp; exec @ARGV or die' sh -c "$test" > /dev/null 2>&1 &
  group=$!
  if [ -n "$limit" ]; then
    perl -e 'setpgrp; exec @ARGV or die' sh -c "sleep $limit; : > '$backup.expired'; kill -KILL -$group" > /dev/null 2>&1 &
    timer=$!
  fi
  if wait "$group" 2> /dev/null; then outcome=pass; else outcome=fail; fi
  stop
  if [ -e "$backup.expired" ]; then outcome=timeout; fi
}

given=$limit limit=
start=$(date +%s)
if ! { [ -z "$build" ] || sh -c "$build"; } > /dev/null 2>&1 || ! { run_test && [ "$outcome" = pass ]; }; then
  echo "mutate.sh: BUILD or TEST fails with no mutation applied, so no red would mean anything: $test" >&2
  exit 2
fi
limit=${given:-$((($(date +%s) - start) * 5 + 60))}

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
  else
    run_test
    case $outcome in
    pass) result=GREEN ;;
    fail) result=red ;;
    *) result=timeout ;;
    esac
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
