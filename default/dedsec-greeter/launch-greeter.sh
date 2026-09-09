#!/bin/bash

# Launch the DedSec greeter (Quickshell) in the given mode: greetd or lockd.
#
# Quickshell's output is kept in /tmp/dedsec-greeter-<user>.log so a blank
# login screen can be diagnosed. If Quickshell dies within a few seconds, which
# is what happens when a virtual GPU cannot give Qt a usable OpenGL context,
# it is relaunched with Mesa's software renderer.

mode="${1:-greetd}"
log="/tmp/dedsec-greeter-${USER:-$(id -un)}.log"

launch() {
  echo "[$(date '+%F %T')] starting quickshell mode=$mode ${LIBGL_ALWAYS_SOFTWARE:+(software rendering)}" >>"$log"
  QT_QPA_PLATFORM=wayland DEDSEC_MODE="$mode" quickshell --path /opt/dedsec/Greeter >>"$log" 2>&1
}

# VM virtual GPUs cannot give Qt a hardware GL context (the lock surface dies
# with "invalid arguments for wl_surface.attach"), so skip the failed first
# attempt on VMware, VirtualBox, and Hyper-V
if grep -qiE 'vmware|virtualbox|innotek|microsoft corporation' /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/product_name 2>/dev/null; then
  export LIBGL_ALWAYS_SOFTWARE=1
fi

started=$(date +%s)
launch
code=$?

if (( code != 0 && $(date +%s) - started < 10 )); then
  echo "[$(date '+%F %T')] quickshell exited with code $code right away, retrying with software rendering" >>"$log"
  export LIBGL_ALWAYS_SOFTWARE=1
  # A locker that died mid-lock leaves Hyprland showing its crashed-lock screen,
  # which blocks a new lock until it is cleared.
  if [[ $mode == "lockd" ]]; then
    hyprctl eval 'hl.clear_crashed_lockscreen()' >>"$log" 2>&1 || true
  fi
  launch
  code=$?
fi

echo "[$(date '+%F %T')] quickshell exited with code $code" >>"$log"
exit "$code"
