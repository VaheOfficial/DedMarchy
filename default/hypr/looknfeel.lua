-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

-- DedSec: neon green to cyan active border, cold blue inactive.
local active_border_color = { colors = { "rgba(00FF41cc)", "rgba(00E5FFcc)" }, angle = 45 }
local inactive_border_color = "rgba(1E304488)"

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 2,

    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },

    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 0,

    shadow = {
      enabled = true,
      range = 6,
      render_power = 2,
      color = "rgba(00FF4118)",
    },

    blur = {
      enabled = true,
      size = 4,
      passes = 3,
      special = true,
      brightness = 0.50,
      contrast = 0.85,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },

    groupbar = {
      font_size = 12,
      font_family = "JetBrainsMono Nerd Font",
      font_weight_active = "ultraheavy",
      font_weight_inactive = "normal",
      indicator_height = 1,
      indicator_gap = 4,
      height = 22,
      gaps_in = 2,
      gaps_out = 0,
      text_color = "rgb(B0F4E6)",
      text_color_inactive = "rgba(B0F4E660)",
      col = {
        active = "rgba(00FF4120)",
        inactive = "rgba(050A0E40)",
      },
      gradients = true,
      gradient_rounding = 0,
      gradient_round_only_edges = false,
    },
  },

  animations = {
    enabled = true,
  },
})

-- DedSec animations: fast and decisive, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("snappy", { type = "bezier", points = { { 0.2, 1 }, { 0.3, 1 } } })
hl.curve("instant", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1 } } })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "snappy" })
hl.animation({ leaf = "windows", enabled = true, speed = 2.8, bezier = "snappy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.4, bezier = "snappy", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.0, bezier = "instant", style = "popin 92%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.8, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "snappy" })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "layers", enabled = true, speed = 2.2, bezier = "snappy" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.4, bezier = "snappy", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.0, bezier = "instant", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.8, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidevert" })

hl.config({
  dwindle = {
    preserve_split = true,
    force_split = 2,
  },

  scrolling = {
    column_width = 0.49,
  },

  master = {
    new_status = "master",
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_scale_notification = true,
    focus_on_activate = true,
    anr_missed_pings = 3,
    on_focus_under_fullscreen = 1,
    initial_workspace_tracking = 0,
    -- Let a fresh shell re-acquire the session lock after the lock client
    -- died, so omarchy-restart-shell can recover the LOCK failsafe.
    allow_session_lock_restore = true,
  },

  cursor = {
    hide_on_key_press = true,
    warp_on_change_workspace = 1,
  },

  binds = {
    hide_special_on_workspace_change = true,
  },
})
