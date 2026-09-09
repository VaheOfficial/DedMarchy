-- Virtual machine tweaks, applied only inside VMware, VirtualBox, or Hyper-V guests.
--
-- Their virtual GPUs cannot hand clients a usable hardware GL context: Qt
-- clients such as the DedSec greeter die with "invalid arguments for
-- wl_surface.attach", and the desktop looks unresponsive because hotkeys
-- register but nothing opens. Force Mesa software rendering.
-- On VMware, also offer a display mode slightly smaller than the host window
-- (o.vm_display_mode) so the VMware console keeps mouse focus.
-- See https://www.robwillis.info/2025/11/installing-omarchy-on-vmware-workstation/
-- and https://github.com/omacom/omarchy/discussions/7758

local function read_first_line(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local line = file:read("l")
  file:close()
  return line
end

local vendor = read_first_line("/sys/class/dmi/id/sys_vendor") or ""
local product = read_first_line("/sys/class/dmi/id/product_name") or ""
local dmi = vendor .. " " .. product

local vmware = dmi:find("VMware") ~= nil
local virtualbox = dmi:find("VirtualBox") ~= nil or dmi:find("innotek") ~= nil
local hyperv = dmi:find("Microsoft Corporation") ~= nil

if not (vmware or virtualbox or hyperv) then
  return
end

hl.env("LIBGL_ALWAYS_SOFTWARE", "1")

-- Walker and Elephant are user services started before Hyprland exports its
-- environment, so apps launched from the launcher would miss the flag and hit
-- the virtual GPU, which wedges it. Push the flag into the session manager and
-- restart the launcher services so everything they spawn inherits it.
o.exec_on_start("systemctl --user set-environment LIBGL_ALWAYS_SOFTWARE=1; dbus-update-activation-environment --systemd LIBGL_ALWAYS_SOFTWARE=1; omarchy-restart-walker")

if not vmware then
  return
end

-- Offer a mode a little smaller than the VM window for the virtual display.
-- This only sets o.vm_display_mode; the catch-all rule in ~/.config/hypr/monitors.lua
-- decides whether to use it, so a mode or scale set there always wins.
local margin_width, margin_height = 20, 30

for card = 0, 2 do
  for index = 1, 4 do
    local preferred = read_first_line("/sys/class/drm/card" .. card .. "-Virtual-" .. index .. "/modes")
    if preferred then
      local width, height = preferred:match("^(%d+)x(%d+)")
      if width and height then
        width = tonumber(width) - margin_width
        height = tonumber(height) - margin_height
        if width >= 640 and height >= 480 and not o.vm_display_mode then
          o.vm_display_mode = width .. "x" .. height .. "@60"
        end
      end
    end
  end
end
