#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Load Colors
source ~/.dotfiles/scripts/colors.sh

# Set env
IP2SEND=192.168.1.169
DEST_USER=zedro
DEST_PATH="~/" # Destination path
PORT=3333 # Port to send audio stream

# Stream Settings
N_CH=2 # Number of channels
RATE=44100 # Bit Rate


# Generate the RTP stream and SDP file
ffmpeg -f alsa -ac $N_CH -ar $RATE -i default -acodec pcm_s16le -f rtp rtp://$IP2SEND:$PORT -sdp_file stream.sdp

# Modify the SDP file to set `m=audio` with payload type 97
sed -i 's/^m=audio [0-9]* RTP\/AVP [0-9]*/m=audio 3333 RTP\/AVP 97/' stream.sdp

# Transfer the SDP file to the Mac
scp stream.sdp $DEST_USER@$IP2SEND:$DEST_PATH

# Clean up
echo -e "${GRN}SDP file has been sent to $IP2SEND:$DEST_PATH${D}"
