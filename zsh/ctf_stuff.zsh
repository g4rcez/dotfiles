# CTF Stuff

# Please, look my repo: github.com/vandalvnl/whatcripto
whatcripto(){
    python $HOME/CTF/MyTools/whatcripto/whatcripto "$@" | fgrep "[+]" | cut -d '>' -f2- | cut -d ' ' -f2-
}

64d(){
    if [[ -e "$1" ]]; then
        cat "$1" | base64 -d
    else
        echo "$@" | base64 -d
    fi
}

64e(){
    if [[ -e "$1" ]]; then
        cat "$1" | base64
    else
        echo "$@" | base64
    fi
}

# Please, look my repo: github.com/vandalvnl/hashingword
md5(){
    python $HOME/CTF/MyTools/hashingword/hashing md5 -s "$@" | fgrep "$@"| cut -d '=' -f2 | cut -d ' ' -f2
}
sha1(){
    python $HOME/CTF/MyTools/hashingword/hashing sha1 -s "$@" | fgrep "$@"| cut -d '=' -f2 | cut -d ' ' -f2
}
sha256(){
    python$HOME/CTF/MyTools/hashingword/hashing sha256 -s "$@" | fgrep "$@"| cut -d '=' -f2 | cut -d ' ' -f2
}
sha512(){
    python $HOME/CTF/MyTools/hashingword/hashing sha512 -s "$@" | fgrep "$@" | cut -d '=' -f2 | cut -d ' ' -f2
}
