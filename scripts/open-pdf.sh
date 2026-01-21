#!/bin/sh


file="$(fd --full-path -e pdf "$PWD" | fzf)" || exit
[ -n "$file" ] && tmux neww -d zathura "$file"

