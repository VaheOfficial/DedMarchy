echo "Start the DedSec greeter through a logging launcher with a software rendering fallback"

if omarchy-cmd-present greetd && [[ -d /opt/dedsec/Greeter ]]; then
  omarchy-refresh-greeter
fi
