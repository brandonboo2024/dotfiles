opts="Lock Suspend Logout Reboot Shutdown"

choice=$(printf '%s\n' $opts | bemenu -i \
  -p 'Power' \
  -l "5 down" \
  --fixed-height \
  -m -1 \
  -n \
  -W 0.25 \
  --fn "Berkeley Mono 14" \
  --tf '#778e8bff' \
  --hf '#778e8bff')

echo $choice

case "$choice" in
  Lock)
    echo "Feature not in place yet."
    ;;
  Suspend)
    echo "Insert Lock command"
    exec systemctl suspend
    ;;
  Logout)
    echo ""


  


