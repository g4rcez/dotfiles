local _plugin_path=$0
local _PWD=`echo $_plugin_path | sed -e 's/\/node-completion\.sh//'`
__zna_pwd="$_PWD"

function __znsaGetScripts() {
  local pkgJson="$1"
  node "$__zna_pwd/node-scripts.js" "$pkgJson" 2>/dev/null
}

function __znsaFindFile() {
  local filename="$1"
  local dir=$PWD
  while [ ! -e "$dir/$filename" ]; do
    dir=${dir%/*}
    [[ "$dir" = "" ]] && break
  done
  [[ ! "$dir" = "" ]] && echo "$dir/$filename"
}

function __znsaArgsLength() {
  echo "$#words"
}

function __znsaYarnRunCompletion() {
  [[ ! "$(__znsaArgsLength)" = "2" ]] && return
  local pkgJson="$(__znsaFindFile package.json)"
  [[ "$pkgJson" = "" ]] && return
  local -a options
  options=(${(f)"$(__znsaGetScripts $pkgJson)"})
  [[ "$#options" = 0 ]] && return
  _describe 'values' options
}

## to lazy to handler different number of arguments
## just copy and paste it
__znsaNpmRunCompletion() {
  [[ ! "$(__znsaArgsLength)" = "3" ]] && return
  local pkgJson="$(__znsaFindFile package.json)"
  [[ "$pkgJson" = "" ]] && return
  local -a options
  options=(${(f)"$(__znsaGetScripts $pkgJson)"})
  [[ "$#options" = 0 ]] && return
  _describe 'values' options
}

__znsaHandleYarn() {
  __znsaYarnRunCompletion
}

__znsaHandleNpm(){
  case "${words[2]}" in
    run)
      __znsaNpmRunCompletion
      ;;
  esac
}

alias nr="npm run"
alias pnpmr="pnpm run"
compdef __znsaYarnRunCompletion yarn
compdef __znsaYarnRunCompletion nr
compdef __znsaYarnRunCompletion pnpm
compdef __znsaYarnRunCompletion pnpmr
compdef __znsaYarnRunCompletion n
compdef __znsaHandleNpm npm
compdef __znsaHandleNpm bun
