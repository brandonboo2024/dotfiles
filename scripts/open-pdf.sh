#!/bin/sh


select="$(
  fd -a -e pdf -e epub . "$PWD" |
  sed "s|$HOME/||" |
  sk --tmux center,80%
  )" || exit 0

[ -n "$select" ] || exit 0

filepath="$HOME/$select"

setsid -f env QT_QPA_PLATFORM=xcb sioyek "$filepath" >/tmp/sioyek.log 2>&1 </dev/null 

# exec env QT_QPA_PLATFORM=xcb sioyek "$file"

