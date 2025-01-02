#!/usr/bin/env bash
# Color Codes
# Run the following command to get list of available colors
# bash -c 'for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done'

# Dracula Color Scheme for Bash

# Text attributes
B="\033[1m"
RESET="\033[0m"
D="\033[0m"

# Standard colors
BLA="\033[38;2;40;42;54m"        # #282a36
RED="\033[38;2;255;85;85m"         # #ff5555
GRN="\033[38;2;80;250;123m"      # #50fa7b
YEL="\033[38;2;241;250;140m"    # #f1fa8c
BLU="\033[38;2;189;147;249m"      # #bd93f9
MAG="\033[38;2;255;121;198m"   # #ff79c6
CYA="\033[38;2;139;233;253m"      # #8be9fd
WHI="\033[38;2;248;248;242m"     # #f8f8f2

# Bright colors
BBLA="\033[38;2;98;114;164m"   # #6272a4 (Comment)
BRED="\033[38;2;255;110;110m"    # #ff6e6e (Unused in standard Dracula)
BGRN="\033[38;2;106;255;173m"  # #6affad (Unused in standard Dracula)
BYEL="\033[38;2;255;255;165m" # #ffffa5 (Unused in standard Dracula)
BBLU="\033[38;2;173;149;255m"   # #ad95ff (Unused in standard Dracula)
BMAG="\033[38;2;255;146;223m"# #ff92df (Unused in standard Dracula)
BCYA="\033[38;2;164;255;255m"   # #a4ffff (Unused in standard Dracula)
BWHI="\033[38;2;255;255;255m"  # #ffffff (Unused in standard Dracula)

# Background colors
BGBLA="\033[48;2;40;42;54m"     # #282a36
BGRED="\033[48;2;255;85;85m"      # #ff5555
BGGRN="\033[48;2;80;250;123m"   # #50fa7b
BGYEL="\033[48;2;241;250;140m" # #f1fa8c
BGBLU="\033[48;2;189;147;249m"   # #bd93f9
BGMAG="\033[48;2;255;121;198m"# #ff79c6
BGCYA="\033[48;2;139;233;253m"   # #8be9fd
BGWHI="\033[48;2;248;248;242m"  # #f8f8f2
