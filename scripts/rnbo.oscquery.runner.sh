#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Request sudo privileges upfront
if [ "$EUID" -ne 0 ]; then
    echo "This script requires sudo privileges. Re-running with sudo..."
    exec sudo -E bash "$0" "$@"
fi

# Preserve environment variables and start logging
exec > >(tee -i setup.log)
echo "Setup script started on $(date)" | tee -a setup.log

# Load Colors
source ~/.dotfiles/scripts/colors.sh

# Function to add the Cycling '74 apt repository, install packages, and setup
setup_c74_repo() {
    echo "${MAG}Setting up Cycling '74 apt repository...${D}"

    echo "${BLU}Downloading Cycling '74 apt repository key and sources...${D}"
    if [ ! -d "rnbo.oscquery.runner" ]; then
        git clone https://github.com/Cycling74/rnbo.oscquery.runner.git
    fi
    cd rnbo.oscquery.runner/config

    echo "${BLU}Adding Cycling '74 apt repository key and sources...${D}"

    cmd1="mv apt-cycling74-pubkey.asc /usr/share/keyrings/"
    echo "$cmd1" && eval "$cmd1"
    ls -al /usr/share/keyrings

    cmd2="mv cycling74.list /etc/apt/sources.list.d/"
    echo "$cmd2" && eval "$cmd2"
    ls -al /etc/apt/sources.list.d

    echo "${BLU}Updating package lists and installing essential packages...${D}"
    apt-get update
    apt-get install --no-install-recommends jackd2 ccache cpufrequtils

    echo "${BLU}Configuring CPU governor for performance...${D}"
    echo "GOVERNOR=\"performance\"" > /etc/default/cpufrequtils

    echo "${BLU}Disabling IPC namespace sharing...${D}"
    echo "RemoveIPC=no" >> /etc/systemd/logind.conf

    echo "${BLU}Upgrading installed packages...${D}"
    apt-get -y upgrade

    echo "${BLU}Cleaning up unnecessary packages...${D}"
    apt-get -y autoremove

    echo "${BLU}Configuring Jack for realtime audio...${D}"
    dpkg-reconfigure jackd2

    echo "${BLU}Enabling dummy audio interface...${D}"
    echo "snd-dummy" >> /etc/modules

    echo "${GRN}Cycling '74 setup complete.${D} 🖔"
}

# Function to install and setup rnbooscquery
setup_rnbooscquery() {
    echo "${MAG}Setting up rnbooscquery...${D}"

    # You can change the version string to match the desired RNBO version
    echo "${BLU}Installing specific version of rnbooscquery...${D}"
    apt-get install -y --allow-change-held-packages --allow-downgrades rnbooscquery=1.3.3

    echo "${BLU}Installing required packages for rnbooscquery...${D}"
    apt-get install -y jack_transport_link rnbo-runner-panel

    echo "${BLU}Marking rnbooscquery package to hold the installed version...${D}"
    apt-mark hold rnbooscquery

    echo "${GRN}rnbooscquery setup complete.${D} 🖔"
}

# Main setup steps
# Set up Cycling '74 repository and install packages
setup_c74_repo

# Set up rnbooscquery
setup_rnbooscquery

# Reboot to apply all changes
echo "${YEL}Rebooting to apply changes...${D}"
reboot
