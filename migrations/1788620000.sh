echo "Render the whole session on the CPU inside VMs, compositor included"

if omarchy-hw-vm; then
  source "$OMARCHY_PATH/install/helpers/chroot.sh"
  source "$OMARCHY_PATH/install/config/hardware/vm.sh"
  [[ -d /opt/dedsec/Greeter ]] && omarchy-refresh-greeter
  echo "Log out and back in for the session to pick this up."
fi
