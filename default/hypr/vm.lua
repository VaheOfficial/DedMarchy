-- Virtual machine tweaks, applied only inside VMware, VirtualBox, or Hyper-V guests.
--
-- Their virtual GPUs cannot hand clients a usable hardware GL context, and
-- mixing a hardware compositor with software apps wedges VMware's virtual GPU.
-- The DedSec setup writes LIBGL_ALWAYS_SOFTWARE=1 to /etc/environment.d so the
-- whole session renders on the CPU; this keeps Hyprland's own children covered
-- when that file is missing, such as a dev checkout before setup has run.
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
