# transer.sh function
transfer() {
  if [ $# -eq 0 ]; then
    echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md";
    return 1;
  fi
  tmpfile=$( mktemp -t transferXXX );
  if tty -s; then
    basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g');
    curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile;
  else
    curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ;
  fi;
  cat $tmpfile;
  rm -f $tmpfile;
}

rule () {
	print -Pn '%F{black}'
	local columns=$(tput cols)
	for ((i=1; i<=columns; i++)); do
	   printf "\u2588"
	done
	print -P '%f'
}

function _my_clear() {
	echo
	rule
	zle clear-screen
}
zle -N _my_clear
bindkey '^l' _my_clear

# extract compacted files
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)  tar -jxvf "$1"                        ;;
      *.tar.gz)   tar -zxvf "$1"                        ;;
      *.bz2)      bunzip2 "$1"                          ;;
      *.dmg)      hdiutil mount "$1"                    ;;
      *.gz)       gunzip "$1"                           ;;
      *.tar)      tar -xvf "$1"                         ;;
      *.tbz2)     tar -jxvf "$1"                        ;;
      *.tgz)      tar -zxvf "$1"                        ;;
      *.zip)      unzip "$1"                            ;;
      *.ZIP)      unzip "$1"                            ;;
      *.pax)      cat "$1" | pax -r                     ;;
      *.pax.Z)    uncompress "$1" --stdout | pax -r     ;;
      *.Z)        uncompress "$1"                       ;;
      *) echo "'$1' cannot be extracted/mounted via extract()" ;;
    esac
  else
     echo "'$1' is not a valid file to extract"
  fi
}

# Get system info 
sysinfo(){
    ps -A --sort -rsz -o pid,comm,pmem,pcpu | awk "NR<=$@"
}

# count words in output
words(){
  egrep -o '\w+' | sort -f | uniq -ci | sort -nr | head $1
}

# Clone and into in cloned git repository
clone()
{
    git clone "${1:?"usage: clone <url_to_clone>"}"
    cd ${${1%%.git}##*/}
}

# Get current path to clipboard && Require alias pbcopy
pwdc(){
  emulate -L zsh
  echo "$(pwd)" | pbcopy
}

filec(){
  emulate -L zsh
  clipcopy "$1"
}

wtf(){
  systemctl status "$1"
}

# Create and Entry in directory
cdir(){
  mkdir "$1" && cd "$1"
}

# Delete the current directory
killme(){
  curdir="$(pwd)"
  cd .. && rm -rf "$curdir"
  ls
}

paclist() {
  # Source: https://bbs.archlinux.org/viewtopic.php?id=93683
  LC_ALL=C pacman -Qei $(pacman -Qu | cut -d " " -f 1) | \
    awk 'BEGIN {FS=":"} /^Name/{printf("\033[1;36m%s\033[1;37m", $2)} /^Description/{print $2}'
}

push(){
  if [[ "$(git config remote.origin.url)" == "" ]]; then 
    echo 'You must be inside a Git repository'; 
  else
    url="$(git config remote.origin.url | sed "s#http\(\|s\)://#&YOUR_USER_HERE:YOUR_PASSWORD_HERE@#g")"
    git push $url $@
  fi
}

whereami(){
  myip=$(curl -s https://4.ifcfg.me/)
  curl -s freegeoip.net/json/$myip | tr ',' '\'n | tr -d "{}" | tr -d '"' | sed 's/^./\u&/g; s/:/:\t/g' | expand -t 20
}

wttr(){
    if [[ "$@" == "" ]]; then
        city="$(whereami | grep "City" | cut -d ':' -f2 | tr -s ' \t'|sed 's/^ \+//g'|sed 's@ @\%20@g')"
    else
        city="$(echo $@ | sed 's@  @\%20@g')"
    fi
    curl -s "wttr.in/$city"
}

has(){
  find "." -iname "$@"
}

contains(){
  has "$@"
}

source ~/.zsh/jsfuncs.zsh
source ~/.zsh/ctf_stuff.zsh

