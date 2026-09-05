-- DedSec theme overrides: neon green borders and slightly translucent terminals.

local active_border_color = { colors = { "rgba(00FF41cc)", "rgba(00E5FFcc)" }, angle = 45 }
local inactive_border_color = "rgba(1E304488)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})

-- Slightly translucent terminals for the surveillance-feed look.
o.window({ tag = "terminal" }, { opacity = "0.95 0.88" })
