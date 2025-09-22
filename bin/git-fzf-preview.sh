function tag() { 
    echo "Tag: $1"
    git log "$1" --pretty
}

$1 $2
