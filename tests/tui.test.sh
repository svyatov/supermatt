#!/bin/sh
# Tests skills/qa/scripts/tui.sh against a program that prompts, answers, and
# exits 3, on a tmux server of its own.
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
TUI="$REPO/skills/qa/scripts/tui.sh"
export TMUX_TMPDIR="$TMP"
unset TMUX
trap 'tmux kill-server 2>/dev/null || true; rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

# The program shows its first screen late, so a wait that does not poll reads
# it blank. The folder icon is U+F07B, and the tab must reach the screen as
# spaces.
cat > "$TMP/prog.sh" <<'EOF'
sleep 0.3
printf 'ready \357\201\273 %s\tend\n' "$1"
read -r line
printf '\033[2J\033[H'
echo "got $line"
sleep 0.5
exit 3
EOF

sh "$TUI" start qa-t 40 10 sh "$TMP/prog.sh" "it's here" || fail "start exited nonzero"

out="$(sh "$TUI" wait qa-t ready 5)" || fail "wait did not see ready: $out"
[ "$out" = "ready [U+F07B] it's here     end" ] || fail "unexpected screen: $out"
[ "$(sh "$TUI" show qa-t | wc -l)" -eq 1 ] || fail "show printed the blank rows below the text"

sh "$TUI" wait qa-t "not on screen" 1 >/dev/null 2>&1 && fail "wait passed on text that never showed"

sh "$TUI" gone qa-t ready 1 >/dev/null 2>&1 && fail "gone passed on text still on screen"

# A key that starts with a dash is text, not a tmux flag.
sh "$TUI" keys qa-t -hello Enter || fail "keys refused a key that starts with a dash"
out="$(sh "$TUI" wait qa-t "got -hello" 5)" || fail "wait did not see the answer: $out"
sh "$TUI" gone qa-t ready 5 >/dev/null || fail "gone did not see ready go"

sh "$TUI" wait qa-t "not on screen" 5 >/dev/null 2>&1 && fail "wait passed after the program exited"
[ "$(tmux display -p -t qa-t '#{pane_dead_status}')" = 3 ] || fail "the pane did not keep the exit status"

sh "$TUI" stop qa-t
tmux has-session -t qa-t 2>/dev/null && fail "stop left the session"

# A program such as a Bubble Tea app reads a key that follows Escape within a
# short window as Alt+key. Nothing may follow Escape within 0.1 seconds.
cat > "$TMP/raw.sh" <<'EOF'
stty -icanon -echo min 1 time 0
echo ready
dd bs=1 count=1 2>/dev/null > /dev/null
sleep 0.1
stty min 0 time 0
echo "after escape:$(dd bs=16 count=1 2>/dev/null)."
sleep 5
EOF
sh "$TUI" start qa-r 40 10 sh "$TMP/raw.sh"
sh "$TUI" wait qa-r ready 5 >/dev/null || fail "the raw program did not start"
sh "$TUI" keys qa-r Escape x
out="$(sh "$TUI" wait qa-r "after escape:" 5)" || fail "the raw program read nothing: $out"
[ "$out" = "ready
after escape:." ] || fail "Escape reached the program with the next key: $out"
sh "$TUI" stop qa-r

echo "ok"
