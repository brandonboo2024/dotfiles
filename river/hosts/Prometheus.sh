# shellcheck shell=sh disable=SC2034

# Prometheus (Yoga): 3200x2000 internal panel driven at scale 1.
#
# Creek sizes are raw pixels and ignore output scale, so set them here.
CURSOR_SIZE=48
BAR_FONT_SIZE=30
BAR_HEIGHT=48

# External mice scroll conventionally; the touchpad stays natural.
NATURAL_SCROLL_DISABLE_PATTERNS="pointer-7847-100-2.4G_Mouse
pointer-1133-45093-Logitech_MX_Anywhere_3"

# Border colours to match the wallpaper, which is set in home/Prometheus.nix.
# BORDER_FOCUSED=0x93a1a1
# BORDER_UNFOCUSED=0x586e75
