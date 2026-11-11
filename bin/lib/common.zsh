# Helpers shared by bin/ scripts (zsh).

# Copies the first argument to the clipboard when pbcopy exists.
clip() {
    (($+commands[pbcopy])) || return 0
    print -rn -- "$1" | pbcopy
}
