# shellcheck shell=sh disable=SC2034
# Hephaestus (desktop). Appearance defaults in river/environment suit this
# machine's monitors, so only what differs belongs here.

# No battery to report on.
BAR_MODULES="cpu ram vol net bt clock"

# Border colours sit against the wallpaper, so set them together. The
# wallpaper itself is owned by Nix: override xdg.configFile."wallpaper" in
# home/Hephaestus.nix rather than pointing WALLPAPER at a path here.
# BORDER_FOCUSED=0x93a1a1
# BORDER_UNFOCUSED=0x586e75
