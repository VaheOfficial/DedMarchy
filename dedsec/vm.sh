#!/bin/bash

# VirtualBox and Hyper-V cannot give a Wayland session usable hardware GL, so
# the whole session renders on the CPU, compositor included. The systemd user
# manager reads this before any unit starts, so the shell, the compositor, and
# every app inherit it. VMware is the exception: with 3D acceleration on it has
# a real render node, and dedsec/vmware.sh sets it up for hardware rendering.

if ! omarchy-hw-vm || omarchy-hw-vmware; then
  exit 0
fi

sudo mkdir -p /etc/environment.d
echo "LIBGL_ALWAYS_SOFTWARE=1" | sudo tee /etc/environment.d/10-dedsec-vm.conf >/dev/null
