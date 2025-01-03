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
INTERFACE=default
CODEC=pcm_s16le 

# Check if running inside tmux
if [ -z "$TMUX" ]; then
  echo -e "${RED}Error: This script must be run inside a tmux session.${D}"
  exit 1
fi

# Generate the RTP stream and SDP file
echo -e "${MAG}Generating RTP stream and SDP file...${D}"
ffmpeg -f alsa -ac $N_CH -ar $RATE -i $INTERFACE -acodec $CODEC \
    -f rtp rtp://$IP2SEND:$PORT -sdp_file stream.sdp

# Transfer the SDP file in a new tmux pane
tmux split-window -v "echo -e '${MAG}Transferring SDP file to $IP2SEND:$DEST_PATH...${D}'${D}'"
tmux send-keys      -t 1 'scp stream.sdp $DEST_USER@$IP2SEND:$DEST_PATH ' C-m

