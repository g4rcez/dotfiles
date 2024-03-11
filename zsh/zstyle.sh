#!/bin/zsh
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export WORDCHARS="${WORDCHARS/\//}"
zmodload -i zsh/complist
unsetopt menu_complete
unsetopt flowcontrol
# use brace
setopt brace_ccl
# Max number of entries to keep in history file.
SAVEHIST=$(( 100 * 1000 ))      # Use multiplication for readability.
# Max number of history entries to keep in memory.
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value
# Use modern file-locking mechanisms, for better safety & performance.
setopt HIST_FCNTL_LOCK
# Keep only the most recent copy of each duplicate entry in history.
setopt HIST_IGNORE_ALL_DUPS
# Auto-sync history between concurrent sessions.
setopt SHARE_HISTORY
setopt aliases
setopt always_to_end
setopt append_history
setopt auto_list
setopt auto_menu         # show completion menu on successive tab press
setopt auto_pushd
setopt autocd
setopt automenu
setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups
setopt complete_in_word
setopt correctall
setopt extended_glob
setopt extended_history
setopt glob_complete      # Show autocompletion menu with globs
setopt globdots
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt histignorealldups
setopt histreduceblanks
setopt magicequalsubst
setopt notify
setopt promptsubst
setopt pushd_ignore_dups
setopt rmstarsilent
setopt share_history
# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
bindkey -M menuselect '^[[Z' reverse-menu-complete
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# ... unless we really want to.
zstyle '*' single-ignored show

color_prompt=yes
force_color_prompt=yes
_comp_options+=(globdots)

zstyle ':completion:*' complete true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=31"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:alias-expension:*' completer _expand_alias
zstyle ':completion:complete:*:options' sort false
############################## key Bind #################################
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^Xa' alias-expension

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS+=("mv " "fg=yellow,bold")
ZSH_HIGHLIGHT_PATTERNS+=("rm -rf " "fg=red,bold")
ZSH_HIGHLIGHT_STYLES[alias]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=yellow"
ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[bracket-level-4]="fg=white"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=yellow"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[function]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[globbing]=fg=063
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[path]="fg=yellow,underline"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=yellow,underline"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=green"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=009

