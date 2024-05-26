#!/bin/zsh
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export WORDCHARS="${WORDCHARS/\//}"
zmodload -i zsh/complist
unsetopt menu_complete
unsetopt flowcontrol
# use brace
# Max number of entries to keep in history file.
SAVEHIST=$(( 100 * 1000 ))      # Use multiplication for readability.
# Max number of history entries to keep in memory.
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value
# Reference: https://zsh.sourceforge.io/Doc/Release/Options.html
setopt PROMPT_SUBST
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD
setopt HIST_SAVE_NO_DUPS

############################## key Bind #################################
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
# zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
# should this be in keybindings?
bindkey '^Xa' alias-expension
bindkey -M menuselect '^o' accept-and-infer-next-history
bindkey -M menuselect '^[[Z' reverse-menu-complete
color_prompt=yes
force_color_prompt=yes
_comp_options+=(globdots)

############################## zstyle #################################
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR
zstyle ':completion:*' complete true
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' file-sort access
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*:*:cp:*' file-sort size
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=31"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:alias-expension:*' completer _expand_alias
zstyle ':completion:complete:*:options' sort false

source $DOTFILES/zsh/syntax-highlighting.zsh
