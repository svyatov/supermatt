# Driving a terminal program

Run the program in a detached tmux session, so you type into it and read its screen as a user at a terminal does. A one-shot command that reads no keys can run straight from the shell; tmux is for anything that prompts, redraws the screen, or runs until stopped.

Drive it with [`scripts/tui.sh`](scripts/tui.sh), bundled with this skill. Start each shell call that drives it with the function `tui() { sh <this skill's directory>/scripts/tui.sh "$@"; };`, then run `tui <command> qa-<name> ...`. The function works in zsh and bash alike, and it calls the script through `sh`, because an installed copy can lose its execute bit.

- **Start** at a fixed size, so the layout stays the same between captures. Run every scenario twice, in a big terminal and a small one, since a layout that fits one can wrap, truncate, or overlap in the other: `tui start qa-<name> 215 60 env HOME=$DIR/home PATH=$DIR/bin:$PATH PROGRAM`, then a fresh session at `80 24`. Record the result at each size; a fail at either size fails the scenario. Judge the fit by the right edge: each frame's right border and each row's last word show in full. tmux clips a row at the pane's edge and a capture drops trailing spaces, so a layout too wide for the pane shows as a cut border, and counting a row's characters cannot find it. `start` runs the program from a launch script with the environment you give it, turns its tabs into spaces, and keeps the pane after the program exits or crashes, so its last screen and exit status stay to read.
- **Type** with `tui keys qa-<name> KEY...`: text, or a key name such as `Enter`, `Up`, `Down`, `Tab`, `Escape`, `BSpace`, `C-c`. Send text that could read as a key name with `tmux send-keys -t qa-<name> -l -- '<text>'`, where `--` keeps text that starts with a dash from reading as a flag.
- **Wait and read** after every step with `tui wait qa-<name> '<expected text>' [SECONDS]`. It polls until the text shows and prints the screen, or exits 1 with the screen it saw once the time limit (10 seconds by default) passes or the program exits first, so a slow program fails the scenario instead of being read too early. Pick text that fits on one screen line, since a narrow pane wraps a long message. Check that text went away with `tui gone qa-<name> '<text>' [SECONDS]`, which polls the same way until the text is off the screen. Both drop the blank rows below the text and names each Nerd Font icon by its code point, as `[U+F07B]`. `tui show qa-<name>` prints the screen the same way without waiting. Use `tmux capture-pane -p -t qa-<name>` with `-S -` for the scrollback, and with `-e` when color is part of the expected result.
- **Exit status**: once the program exits, read it with `tmux display -p -t qa-<name> '#{pane_dead_status}'`.
- **Stop** with `tui stop qa-<name>`.

Unhappy paths a terminal program adds:

- An error exits non-zero and prints its message to stderr.
- `C-c` midway exits cleanly and leaves the terminal usable. Run this one in a plain shell, so the shell comes back to show it: `tmux new-session -d -s qa-<name> -x 215 -y 60`, then type `env HOME=$DIR/home PATH=$DIR/bin:$PATH PROGRAM` with `tmux send-keys`. Put the environment on the typed command, since the session's login shell rebuilds `PATH` from its profile.
- Output piped into `cat` (not a TTY) carries no color codes and no prompts.
- A terminal UI redraws when the window shrinks mid-run: start at the big size, then `tmux resize-window -t qa-<name> -x 80 -y 24`.
