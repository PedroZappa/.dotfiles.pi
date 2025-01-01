#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Load Colors
source ~/.dotfiles/scripts/colors.sh

# **************************************************************************** #
# **************************************************************************** #

# Function to display the public key and prompt for confirmation
display_and_confirm_ssh_key() {
    local pub_key_file="$HOME/.ssh/id_rsa.pub"

    if [ -f "$pub_key_file" ]; then
        echo "${BLU}Here is your public SSH key:${D}"
        cat "$pub_key_file"
        echo "${YEL}Please copy the above key to your remote server or service.${D}"
        read -p "Press [Enter] once you've copied the key, or [Ctrl+C] to abort... "
    else
        echo "${RED}SSH public key file not found!${D}"
        exit 1
    fi
}

# Function to create SSH key if it doesn't exist
create_ssh_key() {
    local key_file="$HOME/.ssh/id_rsa"

    if [ ! -f "$key_file" ]; then
        echo "${MAG}Creating SSH key pair...${D}"
        ssh-keygen
    else
        echo "${YEL}SSH key already exists at $key_file. Skipping key generation.${D}"
    fi
    display_and_confirm_ssh_key
}

# Function to set the default shell
set_default_shell() {
    local shell_path="$1"

    # Check if the shell exists
    if command -v "$shell_path" &>/dev/null; then
        echo "${MAG}Setting default shell to: $shell_path${D}"
        chsh -s "$shell_path"
        echo "${YEL}Shell set to $shell_path. Please log out and log back in for the change to take effect.${D}"
    else
        echo "${RED}Shell not found: $shell_path${D}"
        exit 1
    fi
}

# Function to check if Zap is installed and install if necessary
install_zap() {
    local zap_check_cmd="command -v zap"
    local zap_install_cmd="zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1"

    echo "${BLU}Checking if Zap is installed...${D}"

    if eval "$zap_check_cmd" &>/dev/null; then
        echo "${GRN}Zap is already installed.${D}"
    else
        echo "${YEL}Zap is not installed. Installing now...${D}"
        eval "$zap_install_cmd"
        echo "${GRN}Zap installation complete.${D}"
    fi
}
#
# **************************************************************************** #
# **************************************************************************** #

# Define package categories in separate variables for better maintainability
core_tools=("build-essential" "cmake" "g++" "make" "git" "tmux" "curl" "wget" "vim" "clang" "valgrind" "gdb" "libssl-dev" "libboost-all-dev" "ninja-build" "googletest")
additional_tools=("snapd" "luarocks" "btop" "tree" "ripgrep" "ncdu" "fzf" "ranger")
snap_packages=("nvim --classic")
# python_libraries=("numpy" "scipy" "soundfile" "pyserial")

# Function to install a single apt package
install_package() {
    local pkg="$1"
    echo "${GRN}Installing package: ${BGRN}$pkg${D}"
    sudo apt install -y "$pkg"
}

# Function to install a single snap package
install_snap_package() {
    local pkg="$1"
    echo "${GRN}Installing snap package: ${BGRN}$pkg${D}"
    sudo snap install $pkg
}

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
#
# **************************************************************************** #
#                                 GO BASH GO!                                  #
# **************************************************************************** #

# Create SSH key and confirm with the user
create_ssh_key

# Update package lists
echo "${BLU}Updating package lists...${D}"
sudo apt update
# Upgrade installed packages to the latest version
echo "${BBLU}Upgrading installed packages...${D}"
sudo apt upgrade -y

# Install prefered shell and set it as the default
install_package "zsh"
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    set_default_shell "/usr/bin/zsh"
fi
# Install Zap Zsh's Package Manager
install_zap

# Install the core tools
for pkg in "${core_tools[@]}"; do
    install_package "$pkg"
done

# Install additional tools
for pkg in "${additional_tools[@]}"; do
    install_package "$pkg"
done

# Clean up to save space
echo "${YEL}Cleaning up...${D}"
sudo apt autoremove -y
sudo apt clean

# Install snap packages
echo "${MAG}Installing snap packages...${D}"
install_snap_package "${snap_packages[@]}"

# Install Python libraries using pip
# echo "Installing Python libraries..."
# pip3 install --user ${PACKAGES["python_libraries"]}

if [ ! -d "$HOME/.dotfiles" ]; then
    # Clone the dotfiles repository
    echo "${BLU}Cloning dotfiles repository...${D}"
    git clone "$DOTFILES_SSH_URL" "$HOME/.dotfiles"
fi

for SRC in "${!FILES[@]}"; do
    DEST=${FILES[$SRC]}
    create_symlink "$SRC" "$DEST"
done

# **************************************************************************** #
# **************************************************************************** #


