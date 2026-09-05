if omarchy-hw-vmware; then
  omarchy-pkg-add open-vm-tools
  chrootable_systemctl_enable vmtoolsd.service
  chrootable_systemctl_enable vmware-vmblock-fuse.service
fi
