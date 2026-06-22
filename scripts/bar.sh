#!/bin/sh

# POSIX-compliant creek status bar with modular functions

# ─── CPU Module ─────────────────────────────────────
cpu_module() {
    cpu_line=$(sed -n '1p' /proc/stat)
    cpu_idle1=$(printf '%s\n' "$cpu_line" | awk '{print $5}')
    cpu_total1=$(printf '%s\n' "$cpu_line" | awk '{sum=$2+$3+$4+$5+$6+$7+$8} END {print sum}')

    sleep 1

    cpu_line=$(sed -n '1p' /proc/stat)
    cpu_idle2=$(printf '%s\n' "$cpu_line" | awk '{print $5}')
    cpu_total2=$(printf '%s\n' "$cpu_line" | awk '{sum=$2+$3+$4+$5+$6+$7+$8} END {print sum}')

    cpu_idle_diff=$((cpu_idle2 - cpu_idle1))
    cpu_total_diff=$((cpu_total2 - cpu_total1))
    if [ "$cpu_total_diff" -ne 0 ]; then
        cpu_usage=$((100 * (cpu_total_diff - cpu_idle_diff) / cpu_total_diff))
    else
        cpu_usage=0
    fi
    printf '%s%%' "$cpu_usage"
}

# ─── RAM Module ─────────────────────────────────────
ram_module() {
    free -h | awk '/^Mem:/ {print $3}'
}

# ─── Sound Module ───────────────────────────────────
sound_module() {
    if command -v pamixer >/dev/null 2>&1; then
        if [ "$(pamixer --get-mute 2>/dev/null)" = "true" ]; then
            printf 'MUTE'
        else
            vol=$(pamixer --get-volume 2>/dev/null)
            printf '%s%%' "$vol"
        fi
    elif command -v pactl >/dev/null 2>&1; then
        sink=$(pactl info 2>/dev/null | awk '/Default Sink:/ {print $3}')
        if [ -n "$sink" ]; then
            mute=$(pactl list sinks 2>/dev/null | awk -v sink="$sink" '
                /Name:/ {name=$2}
                name == sink {found=1}
                found && /Mute:/ {print $2; exit}
            ')
            vol=$(pactl list sinks 2>/dev/null | awk -v sink="$sink" '
                /Name:/ {name=$2}
                name == sink {found=1}
                found && /Volume:/ {print $5; exit}
            ')
            if [ "$mute" = "yes" ]; then
                printf 'MUTE'
            else
                printf '%s' "$vol"
            fi
        else
            printf 'N/A'
        fi
    elif command -v amixer >/dev/null 2>&1; then
        amixer get Master 2>/dev/null | awk '
            /\[on\]/ {gsub(/[\[\]]/, "", $4); print $4; exit}
            /\[off\]/ {print "MUTE"; exit}
        '
    else
        printf 'N/A'
    fi
}

# ─── Brightness Module ──────────────────────────────
brightness_module() {
    if [ -r /sys/class/backlight/intel_backlight/brightness ] && [ -r /sys/class/backlight/intel_backlight/max_brightness ]; then
        cur=$(cat /sys/class/backlight/intel_backlight/brightness)
        max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
        printf '%s%%' $((100 * cur / max))
    elif [ -r /sys/class/backlight/amdgpu_bl0/brightness ] && [ -r /sys/class/backlight/amdgpu_bl0/max_brightness ]; then
        cur=$(cat /sys/class/backlight/amdgpu_bl0/brightness)
        max=$(cat /sys/class/backlight/amdgpu_bl0/max_brightness)
        printf '%s%%' $((100 * cur / max))
    elif [ -r /sys/class/backlight/nvidia_0/brightness ] && [ -r /sys/class/backlight/nvidia_0/max_brightness ]; then
        cur=$(cat /sys/class/backlight/nvidia_0/brightness)
        max=$(cat /sys/class/backlight/nvidia_0/max_brightness)
        printf '%s%%' $((100 * cur / max))
    else
        for bl in /sys/class/backlight/*; do
            if [ -r "$bl/brightness" ] && [ -r "$bl/max_brightness" ]; then
                cur=$(cat "$bl/brightness")
                max=$(cat "$bl/max_brightness")
                printf '%s%%' $((100 * cur / max))
                return
            fi
        done
        printf 'N/A'
    fi
}

# ─── Date/Time Module ───────────────────────────────
datetime_module() {
    date '+%a %b %d %H:%M:%S'
}

# ─── WiFi Module ────────────────────────────────────
wifi_module() {
    if command -v nmcli >/dev/null 2>&1; then
        wifi=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d':' -f2)
        [ -z "$wifi" ] && wifi="disconnected"
    elif command -v iw >/dev/null 2>&1; then
        wifi=$(iw dev 2>/dev/null | awk '/ssid/ {print $2}')
        [ -z "$wifi" ] && wifi="disconnected"
    else
        wifi="N/A"
    fi
    printf '%s' "$wifi"
}

# ─── Bluetooth Module ───────────────────────────────
bluetooth_module() {
    if ! command -v bluetoothctl >/dev/null 2>&1; then
        printf 'N/A'
        return
    fi

    powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}')
    if [ "$powered" != "yes" ]; then
        printf 'off'
        return
    fi

    connected=$(bluetoothctl devices Connected 2>/dev/null | head -n 1)
    if [ -n "$connected" ]; then
        printf '%s' "$connected" | cut -d' ' -f3-
    else
        printf 'on'
    fi
}

# ─── Battery Module ──────────────────────────────────
battery_module() {
    for bat in /sys/class/power_supply/BAT*; do
        [ -r "$bat/capacity" ] || continue
        cap=$(cat "$bat/capacity")
        status=$(cat "$bat/status" 2>/dev/null)
        case "$status" in
            Charging*)    icon="+" ;;
            Discharging*) icon="-" ;;
            Full | Not\ charging)  icon="=" ;;
            *)            icon="?" ;;
        esac
        printf '%s%s%%' "$icon" "$cap"
        return
    done
    printf 'N/A'
}

# ─── Main Loop ──────────────────────────────────────
while true; do
    cpu=$(cpu_module)
    ram=$(ram_module)
    sound=$(sound_module)
    # brightness=$(brightness_module)
    datetime=$(datetime_module)
    wifi=$(wifi_module)
    bt=$(bluetooth_module)
    bat=$(battery_module)

    printf 'CPU: %s | RAM: %s | BAT: %s | VOL: %s | WiFi: %s | BT: %s | %s\n' \
        "$cpu" "$ram" "$bat" "$sound" "$wifi" "$bt" "$datetime"

    sleep 2
done
