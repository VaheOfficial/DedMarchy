#!/bin/bash

# VMware, VirtualBox, and Hyper-V cannot give a Wayland session usable hardware
# GL, and mixing a hardware compositor with software apps wedges VMware's
# virtual GPU. Render the whole session on the CPU, compositor included, the
# way a Hyper-V guest does. The systemd user manager reads this before any
# unit starts, so the shell, the compositor, and every app inherit it.

if ! omarchy-hw-vm; then
  exit 0
fi

sudo mkdir -p /etc/environment.d
echo "LIBGL_ALWAYS_SOFTWARE=1" | sudo tee /etc/environment.d/10-dedsec-vm.conf >/dev/null

# Hyper-V guest integration services
if [[ $(systemd-detect-virt --vm 2>/dev/null) == "microsoft" ]]; then
  omarchy-pkg-add hyperv
  sudo systemctl enable --now hv_kvp_daemon.service hv_vss_daemon.service
fi
