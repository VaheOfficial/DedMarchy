#!/bin/bash

# VMware guest tools: resolution sync with the window, clipboard, time sync.

if ! omarchy-hw-vmware; then
  exit 0
fi

omarchy-pkg-add open-vm-tools
sudo systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service
