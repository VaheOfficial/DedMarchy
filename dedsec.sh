#!/bin/bash

# DedSec bootstrap for an installed Omarchy 4.
#
# Install Omarchy 4 from the ISO first, boot into the desktop, then run:
#   bash <(curl -sL https://raw.githubusercontent.com/VaheOfficial/DedMarchy/dev/dedsec.sh) [--blackarch]
#
# It clones the DedSec fork into ~/omarchy, links Omarchy's dev channel to it
# (commands, shell, themes, Hyprland defaults, and migrations then come from the
# fork while packages keep coming from Omarchy), and applies the DedSec setup.

set -eEo pipefail

DEDSEC_REPO="${DEDSEC_REPO:-VaheOfficial/DedMarchy}"
DEDSEC_REF="${DEDSEC_REF:-dev}"
DEDSEC_CHECKOUT="${DEDSEC_CHECKOUT:-$HOME/omarchy}"

if (( EUID == 0 )); then
  echo "Run dedsec.sh as your user, not as root." >&2
  exit 1
fi

if [[ ! -d /usr/share/omarchy || ! -x /usr/bin/omarchy-dev-link ]]; then
  echo "Omarchy 4 is not installed. Install it from the ISO first: https://omarchy.org" >&2
  exit 1
fi

echo -e "\e[32mDedSec: fetching $DEDSEC_REPO ($DEDSEC_REF) into $DEDSEC_CHECKOUT\e[0m"
if [[ -d $DEDSEC_CHECKOUT/.git ]]; then
  git -C "$DEDSEC_CHECKOUT" fetch -q origin "$DEDSEC_REF"
  git -C "$DEDSEC_CHECKOUT" checkout -q "$DEDSEC_REF"
  git -C "$DEDSEC_CHECKOUT" pull -q --ff-only --no-rebase origin "$DEDSEC_REF"
else
  git clone -q --branch "$DEDSEC_REF" "https://github.com/$DEDSEC_REPO.git" "$DEDSEC_CHECKOUT"
fi

echo -e "\e[32mDedSec: linking Omarchy to the checkout\e[0m"
"$DEDSEC_CHECKOUT/bin/omarchy-dev-link" "$DEDSEC_CHECKOUT" --no-reboot

export OMARCHY_PATH="$DEDSEC_CHECKOUT"
export PATH="$OMARCHY_PATH/bin:$PATH"

bash "$OMARCHY_PATH/dedsec/setup.sh" "$@"

echo
echo -e "\e[32mDedSec is set up. Reboot to start the linked session.\e[0m"
if gum confirm "Reboot now?"; then
  systemctl reboot
fi
