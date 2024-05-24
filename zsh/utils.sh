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
