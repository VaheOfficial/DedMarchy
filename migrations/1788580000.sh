echo "Sync DedSec with upstream Omarchy: Lua Hyprland config, Walker launcher, foot terminal"

# Rofi was replaced by Walker for the app launcher
rm -rf ~/.config/rofi

# Foot is the default terminal now
omarchy-pkg-add foot
omarchy-refresh-config foot/foot.ini
omarchy-default-terminal foot

# Pick up the DedSec look ported to the Lua config, the reworked bar, and the new boot splash
omarchy-refresh-hyprland
omarchy-refresh-waybar
omarchy-refresh-plymouth
omarchy-theme-refresh
