#!/bin/sh

# obs
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots >/dev/null 2>&1


# dms shell
dms run --daemon

# keep clipboard content
wl-clip-persist --clipboard regular --reconnect-tries 0 >/dev/null 2>&1 &

# clipboard content manager
wl-paste --type text --watch cliphist store >/dev/null 2>&1 &

# inhibit by audio
sway-audio-idle-inhibit >/dev/null 2>&1 &
