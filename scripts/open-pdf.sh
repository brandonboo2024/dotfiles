#!/bin/sh

select="$(
    fd -a -I -e pdf -e epub --full-path . '/home/Prometheus/Personal/002_Books/' |
    sed "s|^${HOME}/Personal/002_Books/||" |
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

filepath="$HOME/Personal/002_Books/$select"

setsid -f env sioyek-x11 "$filepath" >/tmp/sioyek.log 2>&1 </dev/null 
