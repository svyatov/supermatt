#!/bin/sh
# Usage: tui.sh start SESSION COLS ROWS COMMAND [ARG...]
#        tui.sh keys SESSION [-l] KEY...
#        tui.sh wait SESSION TEXT [SECONDS]
#        tui.sh gone SESSION TEXT [SECONDS]
#        tui.sh show SESSION
#        tui.sh stop SESSION
#
# Drives a terminal program in a detached tmux session.
#
# start runs COMMAND in a COLS x ROWS session from a launch script, so no
# command line is typed into the pane. Tabs reach the screen as spaces, and the
# pane stays after COMMAND exits, so its last screen and its exit status
# (tmux display -p -t SESSION '#{pane_dead_status}') remain to read. Put the
# environment on COMMAND: env HOME=... PATH=... PROGRAM.
#
# keys sends each KEY through tmux send-keys: text, or a key name such as
# Enter, Escape, BSpace, Up, or C-c. A -l sends the KEY after it as literal
# text, so text that reads as a key name is typed as written. It pauses after
# Escape, so the next key does not reach the program as Alt+key, and it escapes
# a trailing ;, which tmux would read as its command separator.
#
# wait polls the screen every 0.1 seconds until it contains TEXT, a fixed
# string, and prints it. It exits 1 and prints the screen once SECONDS (a whole
# number, 10 by default) pass, or once the program has exited without showing
# TEXT. TEXT must fit on one line of the screen, since a narrow pane wraps a
# long message. gone does the same until TEXT is off the screen.
#
# show prints the screen without trailing blank lines, and
# each Nerd Font icon (a private use code point) as [U+XXXX].
set -u

usage() {
  echo "usage: tui.sh start SESSION COLS ROWS COMMAND [ARG...] | keys SESSION [-l] KEY... |" \
    "wait SESSION TEXT [SECONDS] | gone SESSION TEXT [SECONDS] | show SESSION | stop SESSION" >&2
  exit 2
}

start() {
  [ $# -ge 4 ] || usage
  session=$1 cols=$2 rows=$3
  shift 3
  launch="$(mktemp "${TMPDIR:-/tmp}/tui-launch.XXXXXX")"
  {
    echo 'rm -f "$0"'
    echo 'stty oxtabs 2>/dev/null || stty tab3'
    printf exec
    for arg; do
      printf " '%s'" "$(printf '%s' "$arg" | LC_ALL=C sed "s/'/'\\\\''/g")"
    done
    echo
  } > "$launch"
  tmux new-session -d -s "$session" -x "$cols" -y "$rows" -c "$PWD" 'sleep 86400' &&
    tmux set-option -t "$session" remain-on-exit on > /dev/null &&
    tmux respawn-pane -k -t "$session" "sh '$launch'"
}

# keys pauses after Escape, since a program reads Escape and the key right after it as one Alt+key.
keys() {
  session=$1
  shift
  literal=
  for key; do
    if [ "$key" = -l ] && [ -z "$literal" ]; then
      literal=-l
      continue
    fi
    case $key in
      *\;) key="${key%;}\\;" ;; # tmux reads a trailing ; as its command separator
    esac
    tmux send-keys -t "$session" $literal -- "$key" || exit 1
    literal=
    if [ "$key" = Escape ]; then
      sleep 0.2
    fi
  done
}

show() {
  tmux capture-pane -p -t "$1" |
    perl -CSD -0777 -pe 's/([\x{e000}-\x{f8ff}\x{f0000}-\x{10ffff}])/sprintf("[U+%04X]", ord $1)/ge; s/\n+\z/\n/'
}

# wait_for polls until TEXT is on the screen (want=yes) or off it (want=no).
wait_for() {
  want=$1 session=$2 text=$3 tries=$((${4:-10} * 10))
  while :; do
    # Read whether the program has exited before the screen, so a dead pane's screen is final.
    dead="$(tmux display -p -t "$session" '#{pane_dead}')" || exit 1
    screen="$(show "$session")"
    case $screen in
    *"$text"*) shown=yes ;;
    *) shown=no ;;
    esac
    if [ "$shown" = "$want" ]; then
      printf '%s\n' "$screen"
      return 0
    fi
    if [ "$dead" = 1 ] || [ "$tries" -le 0 ]; then
      printf '%s\n' "$screen"
      echo "tui.sh: timed out while \"$text\" on screen was still $shown" >&2
      return 1
    fi
    tries=$((tries - 1))
    sleep 0.1
  done
}

[ $# -ge 2 ] || usage
command=$1
shift
case $command in
start) start "$@" ;;
keys) keys "$@" ;;
wait) [ $# -ge 2 ] || usage; wait_for yes "$@" ;;
gone) [ $# -ge 2 ] || usage; wait_for no "$@" ;;
show) show "$1" ;;
stop) tmux kill-session -t "$1" ;;
*) usage ;;
esac
