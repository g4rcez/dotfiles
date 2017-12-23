# OhMyZSH
alias reload="source ~/.zshrc"

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
alias ls="ls --color"
alias egrep='egrep --color=auto'
alias grep='grep --color=auto'

# For monitor sys
alias cmd10='print -l ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
alias today="date +'%A, %d de %B[%m] de %Y - %H:%M:%S - Semana: %W'"

# ls-icons
alias ls="/opt/coreutils/bin/ls"

# Required Git
alias add="git add ."
alias commit="git commit -m"
alias push="git push"
alias gitrem="git remote add origin"

# Arch - Pacman aliases
alias pacin="sudo pacman -S"
alias pacoptmize="sudo pacman-db-upgrade && sudo pacman-optimize "

# For WebDevs
alias react="create-react-app"
alias npmi="npm install"
alias npms="npm start"

# Prevent troubles
alias sl='ls'
alias cd..='cd ..'
