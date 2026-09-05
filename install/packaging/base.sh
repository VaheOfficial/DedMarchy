# Older DedSec installs shipped the patched omarchy-chromium package, which owns
# the same files as mainline chromium. Swap it out before installing the base set.
for pkg in omarchy-chromium omarchy-chromium-bin; do
  if omarchy-pkg-present "$pkg"; then
    pkill -x chromium 2>/dev/null || true
    sudo pacman -Rdd --noconfirm "$pkg"
  fi
done

# Install all base packages
mapfile -t packages < <(grep -v '^#' "$OMARCHY_INSTALL/omarchy-base.packages" | grep -v '^$')
omarchy-pkg-add "${packages[@]}"
