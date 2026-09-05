echo "Launch the DedSec greeter compositor through start-hyprland with a Lua config"

if omarchy-cmd-present greetd && [[ -d /opt/dedsec/Greeter ]]; then
  omarchy-refresh-greeter
fi
