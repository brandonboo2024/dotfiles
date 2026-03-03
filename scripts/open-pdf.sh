#!/bin/sh


file="$(fd --full-path -e pdf "$PWD" | fzf)" || exit
[ -n "$file" ] && tmux run-shell -b "nohup zathura \"${file}\" >/dev/null 2>&1 </dev/null" 

