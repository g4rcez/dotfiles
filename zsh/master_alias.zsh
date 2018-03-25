# Advanced CP/MV
alias cp="acp -g"
alias mv="amv -g"

# Pbpaste/copy
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

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
    alias ls="/opt/coreutils/bin/ls"
fi

# Required Git
alias add="git add ."
alias commit="git commit -m"
alias gitrem="git remote add origin"

# Arch - Pacman aliases
alias pacin="sudo pacman -S"
alias auri="yaourt -S"
alias pacs="pacman -Ss"
alias aurs="yaourt -Ss"
alias pacoptmize="sudo pacman-db-upgrade && sudo pacman-optimize "

# Debian - Apt aliases
alias apti="sudo apt install "
alias purge="sudo apt purge"
alias search="apt search "


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

# Polybar
alias bar="polybar -r mybar"

# Laravel
alias laravel="/home/garcez/.config/composer/vendor/bin/laravel"
export jekyll="/home/garcez/.gem/ruby/2.4.0/bin/jekyll"
export bundle="/home/garcez/.gem/ruby/2.4.0/bin/bundle"
