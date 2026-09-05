-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

-- Optimized for retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K.
-- local omarchy_gdk_scale = 2
-- local omarchy_monitor_scale = "auto"

-- Good compromise for 27" or 32" 4K monitors (but fractional!): monitor scale 1.6, GDK scale 1.75.
-- local omarchy_gdk_scale = 1.75
-- local omarchy_monitor_scale = 1.6

-- Straight 1x setup for low-resolution displays like 1080p, 1440p, or ultrawides: both 1.
-- local omarchy_gdk_scale = 1
-- local omarchy_monitor_scale = 1

-- Inside VMware, o.vm_display_mode is a mode slightly smaller than the VM window
-- so the VMware console keeps focus (see default/hypr/vm.lua). Replace it with a
-- fixed mode such as "1920x1080@60" to pin the resolution; VMware resizes the
-- preferred mode to match its window, so pick from: hyprctl monitors all
local omarchy_monitor_mode = o.vm_display_mode or "preferred"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = omarchy_monitor_mode, position = "auto", scale = omarchy_monitor_scale })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°)
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Example for Framework 13 w/ 6K XDR Apple display.
-- hl.monitor({ output = "DP-5", mode = "6016x3384@60", position = "auto", scale = 2 })
-- hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto", scale = 2 })

-- Disable the second ghost monitor on an Apple 6K XDR over Thunderbolt.
-- hl.monitor({ output = "DP-2", disabled = true })
