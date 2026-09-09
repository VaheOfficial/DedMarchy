#!/bin/bash

# Hyper-V guest: integration daemons plus Enhanced Session Mode.
#
# VMConnect's Enhanced Session is an RDP client that reaches the guest over an
# AF_VSOCK socket on port 3389 instead of the network. lamco-rdp-server is a
# Wayland-native RDP server that shares the running Hyprland session; DedSec
# builds it from dedsec/pkgs/lamco-rdp-server-vsock and starts it with the
# session from default/hypr/vm.lua through omarchy-launch-hyperv-rdp.
#
# Hyper-V decides whether to offer Enhanced Session when the VM starts, by
# probing that vsock port. A server that only exists once someone is logged in
# is never there for the probe, and the button stays grey. So a socat service
# holds vsock 3389 from boot and forwards each connection to the RDP server on
# loopback TCP 3389. Before login the forward is refused, which VMConnect
# reports and falls back to the basic session; after login it reaches the
# session.
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

# RDP server. A Rust release build: a few minutes on a big VM, and several GB
# of scratch space, so it stays out of /tmp. Rebuilt on a new upstream version
# only; a packaging revision alone is not worth another build.
recipe="$OMARCHY_PATH/dedsec/pkgs/lamco-rdp-server-vsock"
wanted=$(source "$recipe/PKGBUILD" && echo "$pkgver")
installed=$(pacman -Q lamco-rdp-server-vsock 2>/dev/null | awk '{print $2}')
if [[ ${installed%-*} != "$wanted" ]]; then
  echo "Building lamco-rdp-server $wanted..."
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

# Server config: loopback TCP behind the vsock forwarder, plain RDP security
# as VMConnect requires. Left alone once the user has replaced the DedSec copy
# with their own.
mkdir -p ~/.config/lamco-rdp-server
conf=~/.config/lamco-rdp-server/config.toml
if [[ ! -f $conf ]] || grep -q '^# DedSec' "$conf"; then
  sed "s|__HOME__|$HOME|g" "$OMARCHY_PATH/config/lamco-rdp-server/config.toml" >"$conf"
fi

# A server from an earlier config may still hold the vsock port; move it to the
# new config now so the forwarder can bind without a re-login.
if pgrep -x lamco-rdp-server >/dev/null; then
  pkill -x lamco-rdp-server
  sleep 1
  setsid -f omarchy-launch-hyperv-rdp >/dev/null 2>&1
fi

# Boot-time vsock listener, forwarding to the server on loopback
omarchy-pkg-add socat
sudo tee /etc/systemd/system/dedsec-hyperv-esm.service >/dev/null <<'EOF'
[Unit]
Description=Hyper-V Enhanced Session Mode listener (DedSec)
Documentation=https://github.com/VaheOfficial/DedMarchy/blob/dev/DEDSEC.md
After=systemd-modules-load.service
ConditionVirtualization=microsoft

[Service]
ExecStart=/usr/bin/socat VSOCK-LISTEN:3389,fork,reuseaddr TCP:127.0.0.1:3389
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now dedsec-hyperv-esm.service
