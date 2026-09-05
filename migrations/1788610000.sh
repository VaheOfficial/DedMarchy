echo "Add VMware guest support: open-vm-tools, software rendering, and a console-friendly display mode"

if omarchy-hw-vmware; then
  source "$OMARCHY_PATH/install/helpers/chroot.sh"
  source "$OMARCHY_PATH/install/config/hardware/vmware.sh"
  [[ -d /opt/dedsec/Greeter ]] && omarchy-refresh-greeter
fi
