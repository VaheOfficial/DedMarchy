# Always copy the theme files: DedSec ships its own Plymouth theme under the
# "omarchy" name, so an existing Omarchy install would otherwise keep the old files.
sudo mkdir -p /usr/share/plymouth/themes/omarchy
sudo cp -r "$HOME/.local/share/omarchy/default/plymouth/"* /usr/share/plymouth/themes/omarchy/
sudo plymouth-set-default-theme omarchy

# Show the splash immediately instead of after the default delay
sudo mkdir -p /etc/plymouth
if ! grep -q '^ShowDelay=' /etc/plymouth/plymouthd.conf 2>/dev/null; then
  echo "ShowDelay=0" | sudo tee -a /etc/plymouth/plymouthd.conf >/dev/null
fi
