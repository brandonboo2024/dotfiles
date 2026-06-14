#!/bin/sh

select="$(
    fd -a -I -e pdf -e epub --full-path . $HOME'/200_reading/' |
    sed "s|^${HOME}/200_reading/||" |
    bemenu -i \
    -l '10 down' \
    -p 'Open' \
    -c -W 0.5 \
    --fixed-height \
    --fn 'Berkeley Mono 14' \
    --tf '#778e8bff' \
    --hf '#778e8bff'
)" || exit 0

[ -n "$select" ] || exit 0

filepath="$HOME/200_reading/$select"

setsid -f env sioyek-x11 "$filepath" >/tmp/sioyek.log 2>&1 </dev/null 
