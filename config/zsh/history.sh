#!/bin/zsh
SAVEHIST=$((100 * 1000))
HISTSIZE=$((1.2 * SAVEHIST))
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt APPEND_HISTORY        # append to history file (Default)
setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt SHARE_HISTORY         # Share history between all sessions (implies INC_APPEND_HISTORY).
