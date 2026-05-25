#!/bin/sh

pkill -f gnome-keyring 2>/dev/null || true

eval "$(gnome-keyring-daemon --start --components=secrets)"
export SSH_AUTH_SOCK
dbus-update-activation-environment --systemd SSH_AUTH_SOCK

# desktop-session-start >/dev/null 2>&1 &
dms run -d

# keep clipboard content
wl-clip-persist --clipboard regular --reconnect-tries 0 >/dev/null 2>&1 &

# clipboard content manager
wl-paste --type text --watch cliphist store >/dev/null 2>&1 &



# inhibit by audio
# sway-audio-idle-inhibit >/dev/null 2>&1 &
