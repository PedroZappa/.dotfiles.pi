#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Preserve environment variables and start logging
# exec > >(tee -i setup.log)
# echo -e "Setup script started on $(date)" | tee -a setup.log

# Load Colors
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

# Function to add the Cycling '74 apt repository, install packages, and setup
setup_c74_repo() {
    echo -e "${MAG}Setting up Cycling '74 apt repository...${D}"

    echo -e "${BLU}Downloading Cycling '74 apt repository key and sources...${D}"
    if [ ! -d "rnbo.oscquery.runner" ]; then
        git clone https://github.com/Cycling74/rnbo.oscquery.runner.git ~/rnbo.oscquery.runner
    fi
    cd ~/rnbo.oscquery.runner/config

    echo -e "${BLU}Adding Cycling '74 apt repository key and sources...${D}"

    cmd1="mv apt-cycling74-pubkey.asc /usr/share/keyrings/"
    echo -e "$cmd1" && eval "$cmd1"
    ls -al /usr/share/keyrings

    cmd2="mv cycling74.list /etc/apt/sources.list.d/"
    echo "$cmd2" && eval "$cmd2"
    ls -al /etc/apt/sources.list.d

    echo "${BLU}Updating package lists and installing essential packages...${D}"
    apt-get update
    apt-get install --no-install-recommends jackd2 ccache cpufrequtils

    echo -e "${BLU}Configuring CPU governor for performance...${D}"
    echo "GOVERNOR=\"performance\"" > /etc/default/cpufrequtils

    echo -e "${BLU}Disabling IPC namespace sharing...${D}"
    echo "RemoveIPC=no" >> /etc/systemd/logind.conf

    echo -e "${BLU}Upgrading installed packages...${D}"
    apt-get -y upgrade

    echo -e "${BLU}Cleaning up unnecessary packages...${D}"
    apt-get -y autoremove
    
    echo -e "${YEL}Cleaning up rnbo.oscquery.runner temp directory...${D}"
    rm -fr ~/rnbo.oscquery.runner

    echo -e "${BLU}Configuring Jack for realtime audio...${D}"
    dpkg-reconfigure jackd2 jack-tools

    echo -e "${BLU}Enabling dummy audio interface...${D}"
    echo "snd-dummy" >> /etc/modules

    echo -e "${BLU}Adding ${GRN}${USER}${BLU} to ${RED}audioi${BLU} group...${D}"
		sudo usermod -a -G audio $USER

    echo -e "${BGRN}Cycling '74 setup complete.${D} 🖔"
}

# Function to install and setup rnbooscquery
setup_rnbooscquery() {
    echo -e "${MAG}Setting up rnbooscquery...${D}"

    # You can change the version string to match the desired RNBO version
    echo -e "${BLU}Installing specific version of rnbooscquery...${D}"
    apt-get install -y --allow-change-held-packages --allow-downgrades rnbooscquery=1.3.3

    echo -e "${BLU}Installing required packages for rnbooscquery...${D}"
    apt-get install -y jack_transport_link rnbo-runner-panel

    echo -e "${BLU}Marking rnbooscquery package to hold the installed version...${D}"
    apt-mark hold rnbooscquery

    echo -e "${GRN}rnbooscquery setup complete.${D} 🖔"
}

setup_52nvdac() {
    echo -e "${MAG}Setting up 52PI:NVDAC...${D}"
    # Remove the default dtparam=audio=on
    sudo sed -i '/^dtparam=audio=on$/d' /boot/firmware/config.txt
    # Insert dtoverlay=hifiberry-dacplus,slave after the line containing "# Enable audio"
    sudo sed -i '/# Enable audio/a dtoverlay=hifiberry-dacplus,slave' /boot/firmware/config.txt
}

# **************************************************************************** #
# **************************************************************************** #

# Main setup steps
# Set up Cycling '74 repository and install packages
setup_c74_repo

# Set up rnbooscquery
setup_rnbooscquery

# Set up 52nvdac
setup_52nvdac

# Ask user if they want to reboot now
read -p "${RED}Do you want to reboot now? (y/n): ${D}" input

if [[ "$input" =~ ^[Yy]$ ]]; then
    echo -e "${YEL}Rebooting to apply changes...${D}"
    reboot
else
    echo -e "${YEL}Reboot postponed. Please reboot manually later to apply the changes.${D}"
fi

# **************************************************************************** #
# **************************************************************************** #
