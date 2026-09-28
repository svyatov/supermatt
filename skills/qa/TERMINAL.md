# Driving a terminal program

Run the program in a detached tmux session, so you type into it and read its screen as a user at a terminal does. A one-shot command that reads no keys can run straight from the shell; tmux is for anything that prompts, redraws the screen, or runs until stopped.

- **Start** a shell at a fixed size, so the layout stays the same between captures. Run every scenario twice, in a big terminal and a small one, since a layout that fits one can wrap, truncate, or overlap in the other: `tmux new-session -d -s qa-<name> -x 215 -y 60 -c "$DIR"`, then a fresh session with `-x 80 -y 24`. Record the result at each size; a fail at either size fails the scenario. Put the environment the program needs on the command you type (`env HOME=$DIR/home PATH=$DIR/bin:$PATH PROGRAM`). The session's login shell rebuilds `PATH` from its profile and overrides `new-session -e`.
- **Type** with `tmux send-keys -t qa-<name> '<command>' Enter`. Special keys go by name: `Up`, `Down`, `Tab`, `Escape`, `BSpace`, `C-c`. Send text that could read as a key name with `send-keys -l`.
- **Read** the screen with `tmux capture-pane -p -t qa-<name>`. Add `-S -` for the scrollback, and `-e` when color is part of the expected result. When a scenario measures widths, run `stty oxtabs` (Linux: `stty tab3`) in the shell before you launch the program, so tabs it emits reach the capture as spaces.
- **Wait** by polling `capture-pane` until the expected text shows, with a time limit, so a slow program fails the scenario instead of being read too early.
- **Exit status**: once the program exits, send `echo "exit=$?"` and read it off the screen.
- **Stop** with `tmux kill-session -t qa-<name>`.

Unhappy paths a terminal program adds:

- An error exits non-zero and prints its message to stderr.
- `C-c` midway exits cleanly and leaves the terminal usable.
- Output piped into `cat` (not a TTY) carries no color codes and no prompts.
- A terminal UI redraws when the window shrinks mid-run: start at the big size, then `tmux resize-window -t qa-<name> -x 80 -y 24`.
