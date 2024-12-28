#################
### Setup Env ###
#################

# Set language
export LANG=en_US.UTF-8

# Set compiler
export CC=clang
export CXX=clang++

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Github Repos 
export REPOS="$HOME/C0D3/"
export GIT_USER="PedroZappa"

# Dotfiles & Scripts
export DOTFILES="$HOME/.dotfiles"
export SCRIPTS="$DOTFILES/scripts"

# Add ~/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"
# Add 42's ~/homebrew/bin to PATH
# export PATH="$HOME/sgoinfre/homebrew/bin:$PATH"
# Add ~/.dotfiles/scripts to PATH
export PATH="$SCRIPTS:$PATH"
# Add snap to PATH
export PATH=$PATH:/snap/bin

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Preferred applications
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="chromium"

###################
### zsh History ###
###################

export HISTFILE=$XDG_CACHE_HOME/zsh/history
export HISTSIZE=10000
export SAVEHIST=10000
export HISTCONTROL=ignorespace

###################
### Clean up ~/ ###
###################

export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
