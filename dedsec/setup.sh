#!/bin/bash

# DedSec setup on an Omarchy 4 install that is dev-linked to this checkout.
# Run by dedsec.sh; safe to re-run. Pass --blackarch to add the tool groups.

set -eEo pipefail

: "${OMARCHY_PATH:?OMARCHY_PATH must point at the DedSec checkout}"
DEDSEC="$OMARCHY_PATH/dedsec"

blackarch=0
for arg in "$@"; do
  [[ $arg == "--blackarch" ]] && blackarch=1
done

step() { echo -e "\n\e[32m==> $*\e[0m"; }

step "Packages"
omarchy-pkg-add greetd quickshell rustscan

step "Theme"
omarchy-theme-set dedsec

step "Branding"
mkdir -p ~/.config/omarchy/branding
cp -f "$OMARCHY_PATH/logo.txt" ~/.config/omarchy/branding/screensaver.txt
cp -f "$OMARCHY_PATH/icon.txt" ~/.config/omarchy/branding/about.txt

step "Shell prompt"
cp -f "$OMARCHY_PATH/config/starship.toml" ~/.config/starship.toml

step "Menu"
mkdir -p ~/.config/omarchy/extensions
if [[ -f ~/.config/omarchy/extensions/omarchy-menu.jsonc ]] && ! grep -q '"tools"' ~/.config/omarchy/extensions/omarchy-menu.jsonc; then
  cp -f ~/.config/omarchy/extensions/omarchy-menu.jsonc ~/.config/omarchy/extensions/omarchy-menu.jsonc.bak
fi
cp -f "$OMARCHY_PATH/config/omarchy/extensions/omarchy-menu.jsonc" ~/.config/omarchy/extensions/omarchy-menu.jsonc

step "Desktop HUD"
bash "$DEDSEC/eww.sh"

step "Virtual machine support"
bash "$DEDSEC/vmware.sh"
bash "$DEDSEC/vm.sh"

step "Login screen"
bash "$DEDSEC/greetd.sh"

step "Boot splash"
omarchy-refresh-plymouth

if (( blackarch )); then
  step "BlackArch tool groups"
  bash "$DEDSEC/blackarch-repo.sh"
  bash "$DEDSEC/blackarch-essentials.sh"
fi

step "Done"
