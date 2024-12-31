#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Load Colors
source ./colors.sh

# Define package categories in separate variables for better maintainability
core_tools="build-essential cmake g++ make git tmux curl wget vim vim-gtk3 pkg-config clang valgrind gdb python3-pip libtool autoconf automake libssl-dev libboost-all-dev ninja-build clang-tidy clang-format lldb perf cmake-curses-gui libc++-dev libpthread-stubs0-dev libncurses5-dev libtinfo-dev git-lfs git-extras googletest gcovr cppcheck clang-analyzer strace ltrace cmake-doc make-doc gdb-doc"
dsp_libs="jack_transport_link rnbo-runner-panel libsndfile1-dev libjack-jackd2-dev portaudio19-dev libfftw3-dev libasound2-dev libsdl2-dev libpulse-dev"
osc_libraries="libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libzmq3-dev"
additional_tools="zsh htop tree ripgrep ncdu fzf"
# python_libraries="numpy scipy soundfile pyserial"

# Create an associative array for package categories and their variables
declare -A PACKAGES
PACKAGES=(
    ["core_tools"]="$core_tools"
    ["dsp_libs"]="$dsp_libs"
    ["osc_libraries"]="$osc_libraries"
    ["additional_tools"]="$additional_tools"
    # ["python_libraries"]="$python_libraries"
)

# Function to install packages
install_packages() {
    local category=$1
    local packages=$2

    echo "Installing $category..."
    sudo apt install -y $packages
}

# Update package lists
echo "Updating package lists..."
sudo apt update

# Upgrade installed packages to the latest version
echo "Upgrading installed packages..."
sudo apt upgrade -y

# Install packages from the associative array
for category in "${!PACKAGES[@]}"; do
    install_packages "$category" "${PACKAGES[$category]}"
done

# Clean up to save space
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# Install Python libraries using pip
# echo "Installing Python libraries..."
# pip3 install --user ${PACKAGES["python_libraries"]}

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
    DEST=${FILES[$SRC]}
    create_symlink "$SRC" "$DEST"
done
