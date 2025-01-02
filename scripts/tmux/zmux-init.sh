#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Load Colors
source ~/.dotfiles/scripts/colors.sh

# Initialization message
echo ${YEL}ZMUX${D}${PRP}: Initializing Dev Env...${D} ${GRN}${D}

# Command line argument for working directory
if [[ $# -gt 0 ]]; then
    DEV_DIR=$1
else
    DEV_DIR=$HOME  # Default directory if none is provided
fi

# Extract project name from the path
if command -v zoxide &> /dev/null; then
    FULL_DEV_DIR=$(zoxide query "$DEV_DIR") # Use zoxide to get the full path
else
    FULL_DEV_DIR="$DEV_DIR" # Fallback to the provided DEV_DIR if zoxide is not installed
fi
PROJECT_NAME=$(basename "$FULL_DEV_DIR") # Extract the project name

# Session Name variables
SESH1="RC"
SESH2="DEV"

# Create RC session
tmux new-session	-d -s $SESH1
# Create .dotfiles RC window
tmux rename-window	-t RC:1 '.dotfiles'
tmux send-keys		-t RC:1 'cd $HOME/.dotfiles' C-m
tmux send-keys		-t RC:1 'git pull' C-m
# Create JACK Audio Control Kit window
tmux new-window		-t RC:2 -n 'JACK'
tmux send-keys		-t RC:2 'cd $HOME/' C-m
tmux split-window	-t RC:2 -v
tmux send-keys		-t RC:2 'alsamixer' C-m

# Create DEV session
tmux new-session	-d -s $SESH2
# Create Working Project window
tmux rename-window	-t DEV:1 "$PROJECT_NAME"
tmux send-keys		-t DEV:1 'cd '$DEV_DIR C-m
tmux send-keys		-t DEV:1 'clear' C-m

# Attach to DEV session
tmux attach-session -t DEV:1

echo ${YEL}ZMUX${D}${PRP}: Dev Env ${RED}Destroyed!${D} 💣
