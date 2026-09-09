#!/bin/bash

# DedSec desktop HUD: eww widgets for node info, log feed, and diagnostics.

# eww is an AUR package
omarchy-pkg-aur-add eww

mkdir -p ~/.config/eww
cp -f "$OMARCHY_PATH/config/eww/eww.yuck" ~/.config/eww/eww.yuck
cp -f "$OMARCHY_PATH/config/eww/eww.scss" ~/.config/eww/eww.scss
