#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Load Colors
source ./colors.sh

# Associative array defining source and target FILES
declare -A FILES
FILES=(
    ["$HOME/.dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/.dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/.dotfiles/.zshenv"]="$HOME/.zshenv"
    ["$HOME/.dotfiles/.gdbinit"]="$HOME/.gdbinit"
    ["$HOME/.dotfiles/.vimrc"]="$HOME/.vimrc"
	["$HOME/.dotfiles/starship.toml"]="$HOME/.config/starship.toml"
    ["$HOME/.dotfiles/.tmux.conf"]="$HOME/.tmux.conf"
    ["$HOME/.dotfiles/btop/"]="$HOME/.config/"
)
DOTFILES_SSH_URL="git@github.com:PedroZappa/dotfiles.min.git "

# Create symlinks to .dotfiles
create_symlink() {
    local SRC=$1
    local DEST=$2

    # Check if the destination file/directory exists
    if [ -e "$DEST" ]; then
        # If it exists, move it to a backup
        mv "$DEST" "${DEST}_bak"
        echo "${YEL}Moved existing ${PRP}$DEST ${YEL}to ${PRP}${DEST}_bak${D}"
    fi
    # Create the parent directory if it doesn't exist
    mkdir -p "$(dirname "$DEST")"
    # Create the symlink
    ln -s "$SRC" "$DEST"
    echo "${YEL}Created symlink from ${GRN}$SRC ${YEL}to ${PRP}$DEST${D}"
}

for SRC in "${!FILES[@]}"; do
    DEST=${FILES[@]}
    create_symlink "$SRC" "$DEST"
done
