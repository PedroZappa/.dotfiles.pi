#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Preserve environment variables and start logging
# exec > >(tee -i setup.log)
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

setupMIDI() {
    echo -e "${MAG}Beginning MIDI setup...${D}"

    echo -e "${BLU}Set the USB driver to dwc2${D}"
    echo "# Set the USB driver to dwc2" | sudo tee -a /boot/firmware/config.txt
    echo "dtoverlay=dwc2" | sudo tee -a /boot/firmware/config.txt

    echo -e "${BLU}Enable the dwc2 driver${D}"
    echo "# Enable the dwc2 driver" | sudo tee -a /etc/modules
    echo "dwc2" | sudo tee -a /etc/modules

    echo -e "${BLU}Enable the libcomposite driver${D}"
    echo "# Enable the libcomposite driver" | sudo tee -a /etc/modules
    echo "libcomposite" | sudo tee -a /etc/modules

    echo -e "${BLU}Enable the MIDI gadget${D}"
    echo "# Enable the MIDI gadget" | sudo tee -a /etc/modules
    echo "g_midi" | sudo tee -a /etc/modules

    echo -e "${MAG}Creating configuration script...${D}"
    sudo touch /usr/bin/midi_over_usb
    sudo chmod +x /usr/bin/midi_over_usb

    SCRIPT=$(cat <<EOF
        cd /sys/kernel/config/usb_gadget/
        mkdir -p midi_over_usb
        cd midi_over_usb
        echo 0x1d6b > idVendor # Linux Foundation
        echo 0x0104 > idProduct # Multifunction Composite Gadget
        echo 0x0100 > bcdDevice # v1.0.0
        echo 0x0200 > bcdUSB # USB2
        mkdir -p strings/0x409
        echo "fedcba9876543210" > strings/0x409/serialnumber
        echo "Your Name" > strings/0x409/manufacturer
        echo "MIDI USB Device" > strings/0x409/product
        ls /sys/class/udc > UDC
    EOF)
    echo "$SCRIPT" | sudo tee /usr/bin/midi_over_usb
}


# **************************************************************************** #
# **************************************************************************** #

# **************************************************************************** #
# **************************************************************************** #


# **************************************************************************** #
# **************************************************************************** #
