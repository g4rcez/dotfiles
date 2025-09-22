function checkcommand() {
    if [[ -f "$(command -v $1)" ]]; then
        echo -n
    else
        $2
    fi
}

function _postcd() {
    dotenv ".env"
    dotenv ".env.local"
    dotenv "./src/.env"
}

function isGitDir() {
    echo $(git -C "$1" rev-parse --is-inside-work-tree 2>/dev/null)
}

function getCurrentBranch() {
    echo $(git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null)
}

function getRepositoryName() {
    echo $(git -C "$1" config --get remote.origin.url 2>/dev/null | cut -d ':' -f2- | sed ' s/\.git$//g')
}

function basename2() {
    echo $(basename "$(dirname "$1")")/$(basename "$1")
}

function _zellij_tab_name_update() {
    if [[ -n $ZELLIJ ]]; then
        bash "$DOTFILES/bin/zellij-sessionx-rename" "" "$(pwd)"
    fi
}

function forEach() {
    ARRAY=$(echo "$1" | tr ' ' '\n')
    for item in $ARRAY; do
        "$2" $item
    done
}

function fishify() {
    echo $(echo "$1" | perl -pe '
   BEGIN {
      binmode STDIN,  ":encoding(UTF-8)";
      binmode STDOUT, ":encoding(UTF-8)";
   }; s|^$ENV{HOME}|~|g; s|/([^/.])[^/]*(?=/)|/$1|g; s|/\.([^/])[^/]*(?=/)|/.$1|g
')
}

export FZF_COLORS="
--color=dark
--color='bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8'
--color='fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc'
--color='marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'"


