#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Log the output
# exec > >(tee -i pienv_setup.log)
# echo -e "Setup script started on $(date)" | tee -a setup.log

# Load Colors
if [ -d ~/.dotfiles ]; then
    source ~/.dotfiles/scripts/colors.sh
else
    if [ ! -f ~/colors.sh ]; then
        echo -e "${YEL}Colors script not found, downloading: ${D}"
        wget https://raw.githubusercontent.com/PedroZappa/.dotfiles.min/refs/heads/main/scripts/colors.sh
    fi
    source ./colors.sh
fi

# **************************************************************************** #
# **************************************************************************** #

# Function to display the public key and prompt for confirmation
display_and_confirm_ssh_key() {
    local pub_key_file="$HOME/.ssh/id_rsa.pub"

    if [ -f "$pub_key_file" ]; then
        echo -e "${BLU}Here is your public SSH key:${D}"
        cat "$pub_key_file"
        echo -e "${YEL}Please copy the above key to your remote server or service.${D}"
        read -p "Press [Enter] once you've copied the key, or [Ctrl+C] to abort... "
    else
        echo -e "${RED}SSH public key file not found!${D}"
    fi
}

# Function to create SSH key if it doesn't exist
create_ssh_key() {
    local pub_key_file="$HOME/.ssh/id_rsa.pub"

    if [ ! -f "$pub_key_file" ]; then
        echo -e "${MAG}Creating SSH key pair...${D}"
        ssh-keygen
    else
        echo -e "${YEL}SSH key already exists at $pub_key_file. Skipping key generation.${D}"
    fi
    display_and_confirm_ssh_key
}

# Function to set the default shell
set_default_shell() {
    local shell_path="$1"

    # Check if the shell exists
    if command -v "$shell_path" &>/dev/null; then
        echo -e "${MAG}Setting default shell to: $shell_path${D}"
        chsh -s "$shell_path"
        echo -e "${YEL}Shell set to $shell_path. Please log out and log back in for the change to take effect.${D}"
    else
        echo -e "${RED}Shell not found: $shell_path${D}"
        exit 1
    fi
}

# Function to check if Zap is installed and install if necessary
install_zap() {
    local zap_install_cmd="zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1"

    echo -e "${BLU}Checking if Zap is installed...${D}"

    # Check if Zap is installed by looking for its binary or checking its configuration
    if [ -d "$HOME/.local/share/zap" ]; then
        echo -e "${BYEL}Zap is already installed.${D}"
    else
        echo -e "${BMAG}Zap is not installed. Installing now...${D}"
        eval "$zap_install_cmd" || {
            echo "${RED}Failed to install Zap. Please check your network connection and try again.${D}"
            return 1
        }
        rm ~/.zshrc
        echo -e "${BGRN}Zap installation complete.${D}"
    fi
}

# Function to check if Starship is installed and install if necessary
install_starship() {
    local starship_install_cmd="curl -sS https://starship.rs/install.sh | sh"

    echo -e "${BLU}Checking if Starship is installed...${D}"

    # Check if Starship is installed by looking for its binary
    if command -v starship >/dev/null 2>&1; then
        echo -e "${BYEL}Starship is already installed.${D}"
    else
        echo -e "${BMAG}Starship is not installed. Installing now...${D}"
        eval "$starship_install_cmd" || {
            echo -e "${RED}Failed to install Starship. Please check your network connection and try again.${D}"
            return 1
        }
        echo -e "${BGRN}Starship installation complete.${D}"
    fi
}

# **************************************************************************** #
# **************************************************************************** #

# Define package categories in separate variables for better maintainability
core_libs=("build-essential" "clang" "llvm" "g++" "libboost-all-dev" )
core_tools=("vim" "tmux" "gdb" "valgrind" "make" "cmake" "curl" "wget" "ffmpeg" "ninja-build" "googletest")
additional_tools=("snapd" "luarocks" "npm" "btop" "lnav" "tree" "ripgrep" "ncdu" "fzf" "ranger" "nmon" "nmap")
snap_packages=("nvim --classic")

install_package() {
    local pkg=$1
    echo -e "${BLU}Checking if ${pkg} is installed...${D}"
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo -e "${BMAG}${pkg} is not installed. Installing now...${D}"
        sudo apt-get install -y "$pkg" || {
            echo -e "${RED}Failed to install ${pkg}. Please check your package manager or network connection.${D}"
            return 1
        }
    else
        echo -e "${BYEL}${pkg} is already installed.${D}"
    fi
}

# Function to install a single snap package
install_snap_package() {
    local pkg="$1"
    echo -e "${BLU}Checking if snap package ${pkg} is installed...${D}"
    # Check if the snap package is installed
    if ! snap list | grep -q "^${pkg}\s"; then
        echo -e "${BMAG}${pkg} is not installed. Installing now...${D}"
        sudo snap install "$pkg" || {
            echo -e "${RED}Failed to install snap package ${pkg}. Please check your snap configuration or network connection.${D}"
            return 1
        }
    else
        echo -e "${BYEL}${pkg} is already installed.${D}"
    fi
}

# **************************************************************************** #
# **************************************************************************** #

DOTFILES_SSH_URL="git@github.com:PedroZappa/.dotfiles.pi.git"

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
    if ln -s "$SRC" "$DEST"; then
        echo -e "${YEL}Created symlink from ${GRN}$SRC ${YEL}to ${PRP}$DEST${D}"
    else
        echo -e "${RED}Failed to create symlink from ${GRN}$SRC ${RED}to ${PRP}$DEST${D}" >&2
    fi
}

# **************************************************************************** #
#                                 GO BASH GO!                                  #
# **************************************************************************** #

locale="en_US.UTF-8"

# Create SSH key and confirm with the user
create_ssh_key

# Set the locale
sudo localectl set-locale LANG="$locale"

# Update package lists
echo -e "${BLU}Updating package lists...${D}"
sudo apt-get update
# Upgrade installed packages to the latest version
echo -e "${BBLU}Upgrading installed packages...${D}"
sudo apt-get upgrade -y

# Install prefered shell and set it as the default
install_package "zsh"
if [ $SHELL != "/usr/bin/zsh" ]; then
    set_default_shell "/usr/bin/zsh"
fi
# Install Zap Zsh's Package Manager
install_package "git"
install_zap

install_package "curl"
echo -e "${BBLU}Getting Starship Prompt...${D}"
curl -sS https://starship.rs/install.sh | sh

echo -e "${BBLU}Getting TPM (Tmux Plugin Manager)...${D}"
if [ -d ~/.tmux/plugins/tpm ]; then
    echo -e "${BYEL}TPM is already installed at ~/.tmux/plugins/tpm.${D}"
else
    echo -e "${BMAG}TPM is not installed. Cloning now...${D}"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || {
        echo -e "${RED}Failed to clone TPM repository. Please check your internet connection or permissions.${D}"
        exit 1
    }
    echo -e "${GRN}TPM has been successfully installed.${D}"
fi


#
read -p "${BYEL}Do you want to install ${BBLU}Packages? ${BWHI}[y/n]${D}: " input

if [[ "$input" =~ ^[Yy]$ ]]; then
	# Install core libs
	echo -e "${BGRN}Installing Core Libs${D}"
	for pkg in "${core_libs[@]}"; do
			install_package "$pkg"
	done

	# Install core tools
	echo -e "${BGRN}Installing Core Tools${D}"
	for pkg in "${core_tools[@]}"; do
			install_package "$pkg"
	done

	# Install additional tools
	for pkg in "${additional_tools[@]}"; do
			install_package "$pkg"
	done

	# Install snap packages
	echo -e "${BGRN}Installing Snap Packages${D}"
	for pkg in "${snap_packages[@]}"; do
			install_snap_package "$pkg"
	done

	# Clean up to save space
	echo -e "${YEL}Cleaning up...${D}"
	sudo apt-get autoremove -y
	sudo apt-get clean
else
  echo -e "${MAG}Skipping RNBO installation.${D}"
fi

# Clone the dotfiles repository
if [ ! -d "$HOME/.dotfiles" ]; then
    # Clone the dotfiles repository
    echo -e "${BLU}Cloning dotfiles repository...${D}"
    git clone $DOTFILES_SSH_URL $HOME/.dotfiles
fi

# Create symlinks
for SRC in "${!FILES[@]}"; do
    if [ ! -d ~/.config ]; then
        mkdir -p ~/.config
    fi
    DEST=${FILES[$SRC]}
    create_symlink "$SRC" "$DEST"
done

# Install RNBO deps

# Ask the user if they want to install RNBO dependencies
read -p "${BYEL}Do you want to install ${BBLU}RNBO dependencies (including rnbo.oscquery.runner)? ${BWHI}[y/n]${D}: " input

if [[ "$input" =~ ^[Yy]$ ]]; then
    echo -e "${MAG}Proceeding with RNBO setup...${D}"

    if [ -f "~/.dotfiles/scripts/rnbo.oscquery.runner.sh" ]; then
        # If the script exists locally, run it
        echo "${YEL}Found rnbo.oscquery.runner.sh locally. Running...${D}"
        bash ~/.dotfiles/scripts/rnbo.oscquery.runner.sh
    else
        # If the script doesn't exist, clone it and run
        echo -e "${YEL}Cloning rnbo.oscquery.runner.sh from repository...${D}"
        wget https://raw.githubusercontent.com/PedroZappa/.dotfiles.min/refs/heads/main/scripts/rnbo.oscquery.runner.sh
        bash rnbo.oscquery.runner.sh
    fi
else
    echo -e "${MAG}Skipping RNBO installation.${D}"
fi

# Remove the colors script
if [ -f "~/colors.sh" ]; then
    rm ~/colors.sh
fi

# **************************************************************************** #
# **************************************************************************** #
