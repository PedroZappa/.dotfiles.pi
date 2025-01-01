#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Load Colors
source ~/.dotfiles/scripts/colors.sh

# Define package categories in separate variables for better maintainability
core_tools=("build-essential" "cmake" "g++" "make" "git" "tmux" "zsh" "curl" "wget" "vim" "pkg-config" "clang" "valgrind" "gdb" "libssl-dev" "libboost-all-dev" "ninja-build" "perf" "googletest")
additional_tools=("snapd" "htop" "tree" "ripgrep" "ncdu" "fzf")
# python_libraries=("numpy" "scipy" "soundfile" "pyserial")

# Function to install packages
install_packages() {
    local packages=("$@")  # Capture all arguments as an array
    for pkg in "${packages[@]}"; do
        echo "${GRN}Installing package: ${BGRN}$pkg${D}"
        sudo apt install -y "$pkg"
    done
}

# **************************************************************************** #
# **************************************************************************** #

# Update package lists
echo "${BLU}Updating package lists...${D}"
sudo apt update

# Upgrade installed packages to the latest version
echo "${BBLU}Upgrading installed packages...${D}"
sudo apt upgrade -y

# Install the initial batch of packages
install_packages "$core_tools"

# Install additional tools
install_packages "$additional_tools"

# Clean up to save space
echo "${YEL}Cleaning up...${D}"
sudo apt autoremove -y
sudo apt clean

# Install Python libraries using pip
# echo "Installing Python libraries..."
# pip3 install --user ${PACKAGES["python_libraries"]}

# **************************************************************************** #
# **************************************************************************** #

DOTFILES_SSH_URL="git@github.com:PedroZappa/dotfiles.min.git"

# Associative array defining source and target FILES
declare -A FILES
FILES=(
    ["$HOME/.dotfiles/.gitconfig"]="$HOME/.gitconfig"
    ["$HOME/.dotfiles/.zshrc"]="$HOME/.zshrc"
    ["$HOME/.dotfiles/.zshenv"]="$HOME/.zshenv"
    ["$HOME/.dotfiles/.gdbinit"]="$HOME/.gdbinit"
    ["$HOME/.dotfiles/.vimrc"]="$HOME/.vimrc"
    ["$HOME/.dotfiles/.tmux.conf"]="$HOME/.tmux.conf"
    ["$HOME/.dotfiles/btop/"]="$HOME/.config/"
	["$HOME/.dotfiles/starship.toml"]="$HOME/.config/"
	["$HOME/.dotfiles/nvim"]="$HOME/.config/"
)

# Create symlinks to .dotfiles
create_symlink() {
    local SRC=$1
    local DEST=$2

    # Create the parent directory if it doesn't exist
    mkdir -p "$(dirname "$DEST")"
    # Create the symlink
    ln -s "$SRC" "$DEST"
    echo "${YEL}Created symlink from ${GRN}$SRC ${YEL}to ${PRP}$DEST${D}"
}

# **************************************************************************** #
# **************************************************************************** #

# Clone the dotfiles repository
echo "${BLU}Cloning dotfiles repository...${D}"
git clone "$DOTFILES_SSH_URL" "$HOME/.dotfiles"

for SRC in "${!FILES[@]}"; do
    DEST=${FILES[$SRC]}
    create_symlink "$SRC" "$DEST"
done
