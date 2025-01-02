###############
### General ###
###############

# Correct wrong spellings
setopt correct

# Load and initialise completion system
autoload -Uz compinit
compinit
 
# Load colors
autoload -U colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
   eval $COLOR='$fg_no_bold[${(L)COLOR}]'
   eval BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
done
eval NC='$reset_color'

##########################
### Zap Plugin Manager ###
##########################

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zsh-users/zsh-syntax-highlighting"
plug "hlissner/zsh-autopair"
plug "zsh-users/zsh-history-substring-search"
plug "MichaelAquilina/zsh-you-should-use"
plug "zap-zsh/completions"
plug "zap-zsh/sudo"
plug "web-search"
plug "zap-zsh/fzf"
plug "zap-zsh/web-search"
plug "jeffreytse/zsh-vi-mode"
# plug "zap-zsh/zap-prompt"

# git
alias ga='git add'
alias gap='git add -p'
alias gst='git status'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glgg='git log --graph --oneline --decorate'
alias glgs='git log --graph --oneline --decorate | head -n 7'
alias gm='git merge --stat --log'

# vim
alias svim='sudo vim -u ~/.vimrc' 

# Neovim
alias v='nvim'
alias vc='vim | lolcat'
alias clear_nvim='rm -rf ~/.local/share/nvim'

 # tmux
 alias zmux=~/.dotfiles/scripts/tmux/zmux-init.sh
 alias xmux=~/.dotfiles/scripts/tmux/zmux-kill.sh

##############################
### File System Navigation ###
##############################

# cd || zoxide
if command -v zoxide > /dev/null 2>&1; then
	eval "$(zoxide init --cmd cd zsh)"
	echo "[Running ${GREEN}zoxide${NC}! 📂]"
else
	echo "[Running ${YELLOW}cd${NC}! 📂]"
fi

# ls || eza
if command -v eza > /dev/null 2>&1; then
	echo "[Running ${GREEN}eza${NC}! 📊]"
	alias ls='eza'
	alias ll='ls -al'
	alias llx='eza -laZ --total-size'
	alias llg='eza -laZ --total-size --git --git-repos'
else
	echo "[Running ${YELLOW}ls${NC}! ]"
	alias ll='ls -al --color'
fi

############################
### Load Starship Prompt ###
############################

if command -v starship > /dev/null 2>&1; then
   eval "$(starship init zsh)"
else
   ZSH_THEME="refined"
fi

ZSH_THEME="refined"
