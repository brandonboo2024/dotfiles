# Prometheus (Yoga): 3200x2000 internal panel driven at scale 1.
#
# Creek takes its font size and bar height in raw pixels and is not
# scale-aware, which is why these are set per machine rather than relying on
# output scaling.
CURSOR_SIZE=48
BAR_FONT_SIZE=30
BAR_HEIGHT=48

# Border colours sit against the wallpaper, so set them together. The
# wallpaper itself is owned by Nix: override xdg.configFile."wallpaper" in
# home/Prometheus.nix rather than pointing WALLPAPER at a path here.
# BORDER_FOCUSED=0x93a1a1
# BORDER_UNFOCUSED=0x586e75
