function checkcommand() {
    if [[ -f "$(command -v $1)" ]]; then
    else
        $2
    fi
}

function _postcd() {
    dotenv ".env"
    dotenv ".env.local"
    dotenv "./src/.env"
}
