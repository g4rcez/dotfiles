# Sorry, I'm JS developer...It's my job, alright?

# create and up node server for react apps
react(){
    create-react-app $1
    cd $1
    npm install --save axios immutable jwt-decode less less-loader moment ramda react-router redux
    rm -rf node_modules
    npm install
    npm start
}

# clean node_modules/cache and reinstall the node_modules
nodeClean(){
    if [[ -d "$(pwd)/node_modules" ]]; then
        rm -rf "$(pwd)/node_modules"
        rm -rf "$(pwd)/cache"
        npm install 
    fi
}

# Npm commands
alias npmi="npm install"
alias npmis="npm install --save"
alias npmig="sudo npm install -g"
alias npms="npm start"
alias nbuild="npm build"

# Yarn commands
alias yi="yarn install"
alias yb="yarn build"
