# Pbpaste/copy
alias pbcopy="xclip -sel clip"
alias pbpaste='xclip -selection clipboard -o'

# ZSH Config
alias zshconf="vim ~/.zshrc"

# Grep Family
alias fgrep='fgrep --color=auto'
alias ls="ls --color -Fh"
alias egrep='egrep --color=auto'
alias grep='grep --color=auto'

# For monitor sys
alias cmd10='print -l ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
alias today="date +'%A, %d de %B[%m] de %Y - %H:%M:%S - Week: %W'"

# ls-icons
if [[ -e "/opt/coreutils/bin/ls" ]];then
    alias ls="/opt/coreutils/bin/ls --group-directories-first -F"
fi

# Required Git
alias add="git add ."
alias commit="git commit -m"
alias gitrem="git remote add origin"

# Arch - Pacman aliases
# alias pacin="sudo pacman -S"
# alias auri="yaourt -S"
# alias pacs="pacman -Ss"
# alias aurs="yaourt -Ss"
# alias pacoptmize="sudo pacman-db-upgrade && sudo pacman-optimize "

# Debian - Apt aliases
alias search="apt-cache search"
alias install="sudo apt install -y "
alias upgrade="sudo apt upgrade"
alias update="sudo apt update"
alias remove="sudo apt remove"
alias purge="sudo apt remove --purge"
alias autoclean="sudo apt autoclean"
alias autoremove="sudo apt autoremove"
alias reconfigure="sudo dpkg-reconfigure"


# Prevent troubles
alias sl='ls'
alias cd..='cd ..'

# Systemctl Alias
alias start='sudo systemctl start '
alias hello='sudo systemctl start '
alias stop="sudo systemctl stop "
alias restart='sudo systemctl restart '
alias status='sudo systemctl status '

# Root operations
alias root="sudo su"

# Vi => Vim
alias vi="vim"
