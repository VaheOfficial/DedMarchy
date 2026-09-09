#!/bin/bash

# Install the curated BlackArch tool groups. Each group is installed on its own
# so one broken package does not block the rest; a few conflicts are normal.
# Roughly 1,900 packages and 22 GB installed plus an 8 GB download cache.

BLACKARCH_GROUPS=(
  blackarch-recon
  blackarch-scanner
  blackarch-exploitation
  blackarch-webapp
  blackarch-cracker
  blackarch-wireless
  blackarch-sniffer
  blackarch-proxy
  blackarch-forensic
  blackarch-social
  blackarch-fuzzer
)

source "$OMARCHY_PATH/dedsec/blackarch-lib.sh"

for group in "${BLACKARCH_GROUPS[@]}"; do
  echo
  echo ">> Installing $group..."
  blackarch_install_group "$group"
done

echo
echo "BlackArch essentials installation complete."
