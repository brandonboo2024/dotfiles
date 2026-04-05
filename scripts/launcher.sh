#!/bin/sh

# setting for bemenu
cmd="bemenu -i \
  -l '10 down' \
  -p 'Run' \
  -c -W 0.25 \
  --fixed-height \
  --fn 'Berkeley Mono 14' \
  --tf '#778e8bff' \
  --hf '#778e8bff' "

j4-dmenu-desktop --term-mode kitty -d "$cmd"
