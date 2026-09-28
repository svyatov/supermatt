# Driving a terminal program

Run the program in a detached tmux session, so you type into it and read its screen as a user at a terminal does. A one-shot command that reads no keys can run straight from the shell; tmux is for anything that prompts, redraws the screen, or runs until stopped.

- **Start** a shell at a fixed size, so the layout stays the same between captures: `tmux new-session -d -s qa-<name> -x 120 -y 40 -c "$DIR"`.
- **Type** with `tmux send-keys -t qa-<name> '<command>' Enter`. Special keys go by name: `Up`, `Down`, `Tab`, `Escape`, `BSpace`, `C-c`. Send text that could read as a key name with `send-keys -l`.
- **Read** the screen with `tmux capture-pane -p -t qa-<name>`. Add `-S -` for the scrollback, and `-e` when color is part of the expected result.
- **Wait** by polling `capture-pane` until the expected text shows, with a time limit, so a slow program fails the scenario instead of being read too early.
- **Exit status**: once the program exits, send `echo "exit=$?"` and read it off the screen.
- **Stop** with `tmux kill-session -t qa-<name>`.

Unhappy paths a terminal program adds:

- An error exits non-zero and prints its message to stderr.
- `C-c` midway exits cleanly and leaves the terminal usable.
- Output piped into `cat` (not a TTY) carries no color codes and no prompts.
- A terminal UI still draws in a narrow window: `tmux resize-window -t qa-<name> -x 60`.
