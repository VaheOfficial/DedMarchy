-- Minimal Hyprland config for the DedSec greeter session.
-- This runs under the greeter user via greetd, not the user's main session.

-- Use the monitor's preferred mode at 1x
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
  misc = {
    background_color = "rgba(050A0EFF)",
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },

  animations = {
    enabled = false,
  },

  cursor = {
    inactive_timeout = 3,
  },
})

-- Launch the DedSec greeter in greetd mode once the compositor is up
hl.on("hyprland.start", function()
  hl.exec_cmd("env DEDSEC_MODE=greetd quickshell --path /opt/dedsec/Greeter")
end)
