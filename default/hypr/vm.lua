-- Virtual machine tweaks, applied only inside VMware or VirtualBox guests.
--
-- Their virtual GPUs cannot hand clients a usable hardware GL context: Qt
-- clients such as the DedSec greeter die with "invalid arguments for
-- wl_surface.attach", and the desktop looks unresponsive because hotkeys
-- register but nothing opens. Force Mesa software rendering and 1x scaling.
-- On VMware, also run the virtual display slightly smaller than the host
-- window so the VMware console keeps mouse focus.
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

if not (vmware or virtualbox) then
  return
end

hl.env("LIBGL_ALWAYS_SOFTWARE", "1")
hl.env("GDK_SCALE", "1")

if not vmware then
  return
end

-- Pick a mode a little smaller than the preferred one for each virtual output.
-- A specific output rule wins over the catch-all "" rule in the user's monitors.lua.
local margin_width, margin_height = 20, 30

for card = 0, 2 do
  for index = 1, 4 do
    local output = "Virtual-" .. index
    local preferred = read_first_line("/sys/class/drm/card" .. card .. "-" .. output .. "/modes")
    if preferred then
      local width, height = preferred:match("^(%d+)x(%d+)")
      if width and height then
        width = tonumber(width) - margin_width
        height = tonumber(height) - margin_height
        if width >= 640 and height >= 480 then
          hl.monitor({ output = output, mode = width .. "x" .. height .. "@60", position = "auto", scale = 1 })
        end
      end
    end
  end
end
