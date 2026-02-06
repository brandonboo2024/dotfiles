#!/bin/sh

CATEGORIES=(
    "FOR_FUN"
    "VIM"
		"WASTE" 
		"STOP"
)

selected=$(printf "%s\n" "${CATEGORIES[@]}" | sk --margin 10% --color="bw" --bind 'q:abort')
sk_status=$?

if [[ $sk_status -ne 0 || -z "$selected" ]]; then
    exit 0
fi

tmux set -g status-interval 5

if [[ "$selected" == "STOP" ]]; then
    timew stop > /dev/null 2>&1
    tmux set -g status-right ""
else
    timew start "$selected" > /dev/null 2>&1
    tmux set -g status-right "$selected #(timew | awk '/^ *Total/ {print \$NF}')"

fi
