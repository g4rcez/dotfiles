#!/bin/zsh
zmodload -i zsh/complist
WORDCHARS='.*_-[]@~&;:!#$%^(){}<>/\ '
export WORDCHARS="${WORDCHARS/\//}"

############################## setops #################################
# history
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
unsetopt FLOW_CONTROL
## directories
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
############################## setops #################################
# Reference: https://zsh.sourceforge.io/Doc/Release/Options.html
setopt ALWAYS_TO_END
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt AUTO_MENU            # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt PROMPT_SUBST
setopt CDABLE_VARS        # Like AUTO_CD, but for named directories
setopt INTERACTIVE_COMMENTS
setopt COMBINING_CHARS
setopt CORRECT

############################## key Bind #################################
function copy-command() { 
    echo -n $BUFFER | pbcopy
    zle -m 'Copied to clipboard'
}
zle -N copy-command
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^Xa' alias-expension
bindkey "^Xc" copy-command
color_prompt=yes
force_color_prompt=yes
_comp_options+=(globdots)


############################## zstyle #################################
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR
zstyle ':completion:*' use-cache on
zstyle ':completion:*' complete true
# zstyle '*:compinit' arguments -D -i -u -C -w
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' file-sort access
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*:*:cp:*' file-sort size
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:alias-expension:*' completer _expand_alias
zstyle ':completion:complete:*:options' sort false

############################## syntax-highlighting #################################
source $DOTFILES/zsh/syntax-highlighting.zsh
