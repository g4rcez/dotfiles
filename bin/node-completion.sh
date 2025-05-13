#!/bin/bash

function _n_completion() {
    COMMAND="pnpm"
    if [[ -f "package-lock.json" ]]; then
        COMMAND="npm"
        complete -F _npm_completion n
    elif [[ -f "yarn.lock" ]]; then 
        COMMAND="yarn";
    else 
        COMMAND="pnpm";
        complete -F _pnpm_completion n
    fi
    LIST=$(jq '.scripts' package.json | sed '1d;$d' | tr -d ' ' | grep -wo -e '^"[a-z:]*"' | tr -d '"' | tr '\n' ' ')
    COMPREPLY=($(compgen -W "$LIST" -- "${COMP_WORDS[1]}"))    
}

complete -F _n_completion n
