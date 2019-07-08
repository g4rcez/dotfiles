WIFI="$(nmcli -t -c no dev wifi | grep '^*' | cut -d ':' -f2)"

if [[ $WIFI == "" ]]; then
    echo "No Connection"
else
    echo "$WIFI"
fi
