#!/bin/sh

opts="Lock Reboot Shutdown"

choice=$(printf '%s\n' $opts | fuzzel --dmenu --minimal-lines)

echo $choice

case "$choice" in
    Lock)
        ~/nixos/config/scripts/swaylock.sh
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        reboot
        ;;
esac

    


