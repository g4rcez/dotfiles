#!/usr/bin/env bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
# polybar -r mybar  &
polybar -r mybar2 &
