#!/bin/sh


file="$(fd -e pdf -e epub . "$PWD" | fzf)" || exit 0
# [ -n "$file" ] && tmux run-shell -b "nohup sioyek-x11 \"${file}\" >/dev/null 2>&1 </dev/null" 

setsid -f env QT_QPA_PLATFORM=xcb sioyek "$file" >/tmp/sioyek.log 2>&1 </dev/null 

# exec env QT_QPA_PLATFORM=xcb sioyek "$file"

