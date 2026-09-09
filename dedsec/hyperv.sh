#!/bin/bash

# Hyper-V guest: integration daemons plus Enhanced Session Mode.
#
# VMConnect's Enhanced Session is an RDP client that reaches the guest over an
# AF_VSOCK socket on port 3389 instead of the network. lamco-rdp-server is a
# Wayland-native RDP server that shares the running Hyprland session and, when
# built with its `vsock` feature, listens on that socket. The AUR package leaves
# the feature out, so DedSec builds its own package from the same recipe
# (dedsec/pkgs/lamco-rdp-server-vsock). The server starts with the session
# from default/hypr/vm.lua through omarchy-launch-hyperv-rdp.
#
# Host side: Set-VM -EnhancedSessionTransportType HvSocket, done by
# E:\Hyper-VOmarchy\OmarchySetup.ps1.

if ! omarchy-hw-hyperv; then
  exit 0
fi

# Integration services: host time and IP reporting, snapshot quiescing
omarchy-pkg-add hyperv
sudo systemctl enable --now hv_kvp_daemon.service hv_vss_daemon.service

# AF_VSOCK provider for Hyper-V; nothing can bind a vsock port without it
echo hv_sock | sudo tee /etc/modules-load.d/hv_sock.conf >/dev/null
sudo modprobe hv_sock

# Software H.264 for the RDP video stream; a Hyper-V guest has no GPU encoder
omarchy-pkg-add openh264

# RDP server with the vsock listener compiled in. A Rust release build: a few
# minutes on a big VM, and several GB of scratch space, so it stays out of /tmp.
recipe="$OMARCHY_PATH/dedsec/pkgs/lamco-rdp-server-vsock"
wanted=$(source "$recipe/PKGBUILD" && echo "$pkgver-$pkgrel")
installed=$(pacman -Q lamco-rdp-server-vsock 2>/dev/null | awk '{print $2}')
if [[ $installed != "$wanted" ]]; then
  echo "Building lamco-rdp-server $wanted with vsock support..."
  build="$HOME/.cache/dedsec/lamco-rdp-server-vsock"
  rm -rf "$build"
  mkdir -p "$build"
  cp -r "$recipe/." "$build/"
  if (cd "$build" && makepkg -si --noconfirm --needed --nocheck); then
    rm -rf "$build"
  else
    echo -e "\e[31mlamco-rdp-server build failed; Enhanced Session Mode is not available yet. Re-run dedsec/hyperv.sh after fixing the error above.\e[0m" >&2
  fi
fi

# Server config: vsock only, plain RDP security as VMConnect requires.
# Left alone once the user has replaced the DedSec copy with their own.
mkdir -p ~/.config/lamco-rdp-server
conf=~/.config/lamco-rdp-server/config.toml
if [[ ! -f $conf ]] || grep -q '^# DedSec' "$conf"; then
  sed "s|__HOME__|$HOME|g" "$OMARCHY_PATH/config/lamco-rdp-server/config.toml" >"$conf"
fi
