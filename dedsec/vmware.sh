#!/bin/bash

# VMware guest: a GPU-accelerated desktop that follows the window.
#
# With "Accelerate 3D graphics" on, VMware's SVGA3D device gives the guest a
# real render node (vmwgfx + Mesa svga), so Hyprland, the shell, and every app
# render on the host GPU. Three things stand between that and a usable desktop,
# and this script handles all of them:
#
# - Hyprland rejects every client dmabuf on vmwgfx (Omarchy #8113, Hyprland
#   discussion #12966): GPU apps and Quickshell never draw. DedSec builds
#   Omarchy's hyprland package with the fix, dedsec/pkgs/hyprland-vmwgfx.
# - Atomic modesetting hangs page flips and the hardware cursor plane never
#   commits (Omarchy #7918): AQ_NO_ATOMIC=1 and software cursors, from
#   /etc/environment.d and default/hypr/vm.lua.
# - open-vm-tools has no Wayland clipboard (open-vm-tools #510, #792): DedSec
#   builds it with clipway, dedsec/pkgs/open-vm-tools-clipway, and runs the
#   user daemon inside the session through omarchy-launch-vmware-user.
#
# Display resizing follows the VM window through omarchy-hw-vmware-display-watch.
# Shared folders mount under /mnt/hgfs.
#
# Host side: run VMware with Hyper-V off, or it lands in the slow
# Hyper-V-compatible mode. E:\VMwareOmarchy\OmarchySetup.ps1 creates the VM.

if ! omarchy-hw-vmware; then
  exit 0
fi

# Hardware GL for the whole session. The Hyper-V and VirtualBox path forces
# software rendering; on VMware that is exactly what wedges the virtual GPU.
sudo rm -f /etc/environment.d/10-dedsec-vm.conf
sudo mkdir -p /etc/environment.d
echo "AQ_NO_ATOMIC=1" | sudo tee /etc/environment.d/10-dedsec-vmware.conf >/dev/null

# Build one of the recipes under dedsec/pkgs when the installed package is
# not already at the recipe's version. Source builds, so they stay out of /tmp.
build_recipe() {
  local recipe="$OMARCHY_PATH/dedsec/pkgs/$1" query="$2" wanted installed
  wanted=$(source "$recipe/PKGBUILD" && echo "${epoch:+$epoch:}$pkgver-$pkgrel")
  installed=$(pacman -Q "$query" 2>/dev/null | awk '{print $2}')
  if [[ $installed == "$wanted" ]]; then
    return 0
  fi
  # Same upstream version is required: the recipes track Omarchy's and Arch's
  # packages exactly, and a patch against another version is not worth a guess.
  if [[ -n $installed && ${installed%-*} != "${wanted%-*}" ]]; then
    echo -e "\e[33m$query is $installed but dedsec/pkgs/$1 builds ${wanted%-*}; skipping. Update the recipe to match.\e[0m" >&2
    return 1
  fi
  echo "Building $1 ($wanted)..."
  local build="$HOME/.cache/dedsec/$1"
  rm -rf "$build"
  mkdir -p "$build"
  cp -r "$recipe/." "$build/"
  if (cd "$build" && makepkg -si --noconfirm --needed --nocheck); then
    rm -rf "$build"
  else
    echo -e "\e[31m$1 build failed; see the output above and re-run dedsec/vmware.sh.\e[0m" >&2
    return 1
  fi
}

# Hyprland with the vmwgfx dmabuf fix
build_recipe hyprland-vmwgfx hyprland

# Guest tools with the Wayland clipboard backend; falls back to stock tools
build_recipe open-vm-tools-clipway open-vm-tools || omarchy-pkg-add open-vm-tools
sudo systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service

# Chromium browsers blocklist VMware's GPU and fall back to CPU rendering
omarchy-hw-vmware-chromium-flags

# Refresh rate the display watcher requests. 120 is what the virtual GPU
# sustains with DedSec's blur and shadows; the .vmx caps must allow it too.
mkdir -p ~/.config/omarchy
[[ -f ~/.config/omarchy/vmware-refresh ]] || echo 120 >~/.config/omarchy/vmware-refresh

# Shared folders from the VM settings appear under /mnt/hgfs
sudo mkdir -p /mnt/hgfs
if ! grep -q "vmhgfs-fuse" /etc/fstab; then
  echo ".host:/ /mnt/hgfs fuse.vmhgfs-fuse defaults,allow_other,nofail,_netdev 0 0" | sudo tee -a /etc/fstab >/dev/null
fi
sudo mount /mnt/hgfs 2>/dev/null || true
