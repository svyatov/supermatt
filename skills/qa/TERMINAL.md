# Driving a terminal program

Run the program in a detached tmux session, so you type into it and read its screen as a user at a terminal does. A one-shot command that reads no keys can run straight from the shell; tmux is for anything that prompts, redraws the screen, or runs until stopped.

- **Start** a shell at a fixed size, so the layout stays the same between captures. Run every scenario twice, in a big terminal and a small one, since a layout that fits one can wrap, truncate, or overlap in the other: `tmux new-session -d -s qa-<name> -x 215 -y 60 -c "$DIR"`, then a fresh session with `-x 80 -y 24`. Record the result at each size; a fail at either size fails the scenario. Put the environment the program needs on the command you type, and launch it with `exec` after `tmux set-option -t qa-<name> remain-on-exit on` (`exec env HOME=$DIR/home PATH=$DIR/bin:$PATH PROGRAM`): the program replaces the shell, so when it exits or crashes its last screen stays for capture and later keys go nowhere instead of into a shell prompt. The session's login shell rebuilds `PATH` from its profile and overrides `new-session -e`.
- **Type** with `tmux send-keys -t qa-<name> '<command>' Enter`. Special keys go by name: `Up`, `Down`, `Tab`, `Escape`, `BSpace`, `C-c`. Send text that could read as a key name with `send-keys -l`.
- **Read** the screen with `tmux capture-pane -p -t qa-<name>`. Add `-S -` for the scrollback, and `-e` when color is part of the expected result. Before you launch a program that redraws the screen, run `stty oxtabs` (Linux: `stty tab3`) in the shell, so tabs its redraws emit reach the capture as spaces. When the screen draws icons (Nerd Font glyphs sit in the Unicode private use areas), pipe the capture through `ruby -pe '$_.gsub!(/[\u{e000}-\u{f8ff}\u{f0000}-\u{10ffff}]/) { format("[U+%04X]", $&.ord) }'`, so each icon reads as its code point.
- **Wait** by polling `capture-pane` until the expected text shows, with a time limit, so a slow program fails the scenario instead of being read too early.
- **Exit status**: once the program exits, read it with `tmux display -p -t qa-<name> '#{pane_dead_status}'`.
- **Stop** with `tmux kill-session -t qa-<name>`.

Unhappy paths a terminal program adds:

- An error exits non-zero and prints its message to stderr.
- `C-c` midway exits cleanly and leaves the terminal usable. Launch this one without `exec`, so the shell comes back to show it.
- Output piped into `cat` (not a TTY) carries no color codes and no prompts.
- A terminal UI redraws when the window shrinks mid-run: start at the big size, then `tmux resize-window -t qa-<name> -x 80 -y 24`.
