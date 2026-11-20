# shellcheck shell=sh disable=SC2034
# Hephaestus (desktop): river/environment defaults suit its monitors.

# No battery.
BAR_MODULES="cpu ram vol net bt clock"

# Mice only, no touchpad: scroll conventionally on every pointer.
NATURAL_SCROLL_DISABLE_PATTERNS="pointer-*"

# Border colours to match the wallpaper, which is set in home/Hephaestus.nix.
# BORDER_FOCUSED=0x93a1a1
# BORDER_UNFOCUSED=0x586e75
