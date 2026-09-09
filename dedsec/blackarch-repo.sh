#!/bin/bash

# Add the BlackArch repository if it is not configured yet.

if ! grep -q '^\[blackarch\]' /etc/pacman.conf 2>/dev/null; then
  echo "Adding BlackArch repository..."
  tmp=$(mktemp -d)
  curl -sL -o "$tmp/strap.sh" https://blackarch.org/strap.sh
  chmod +x "$tmp/strap.sh"
  sudo "$tmp/strap.sh"
  rm -rf "$tmp"
fi

sudo pacman -Sy --noconfirm
