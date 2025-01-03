#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Create a new tmux pane and execute a command
tmux split-window -h "echo -e 'Pane 2 started' && echo 'This is a command on Pane 2' && zsh || bash"

# Select the previous pane (Pane 0, in this case) and send a command
tmux select-pane -t 1
tmux send-keys -t 1 "echo 'Pane ${TMUX_PANE} command sent'" C-m
