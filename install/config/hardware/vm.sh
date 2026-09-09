if omarchy-hw-vm; then
  # VMware, VirtualBox, and Hyper-V cannot give a Wayland session usable hardware
  # GL. Mixing a hardware compositor with software apps wedges VMware's virtual
  # GPU, so render the whole session on the CPU, compositor included, the way a
  # Hyper-V guest does. The systemd user manager reads this before any unit starts.
  sudo mkdir -p /etc/environment.d
  echo "LIBGL_ALWAYS_SOFTWARE=1" | sudo tee /etc/environment.d/10-dedsec-vm.conf >/dev/null

  # Hyper-V guest integration services
  if [[ $(systemd-detect-virt --vm 2>/dev/null) == "microsoft" ]]; then
    omarchy-pkg-add hyperv
    chrootable_systemctl_enable hv_kvp_daemon.service
    chrootable_systemctl_enable hv_vss_daemon.service
  fi
fi
