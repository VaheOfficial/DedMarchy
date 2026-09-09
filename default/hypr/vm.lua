-- Virtual machine tweaks, applied only inside VMware, VirtualBox, or Hyper-V guests.
--
-- VirtualBox and Hyper-V cannot hand clients a usable hardware GL context, so
-- the DedSec setup writes LIBGL_ALWAYS_SOFTWARE=1 to /etc/environment.d and the
-- whole session renders on the CPU; the env below keeps Hyprland's own children
-- covered when that file is missing, such as a dev checkout before setup has run.
--
-- VMware with 3D acceleration is different: vmwgfx gives the guest a real render
-- node, so everything renders on the host GPU. It needs the patched hyprland
-- from dedsec/pkgs/hyprland-vmwgfx, no atomic modesetting, and software
-- cursors (Omarchy #7918, #8113). dedsec/vmware.sh sets the system side up.

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

if vmware then
  -- Atomic modesetting hangs page flips on vmwgfx, and its cursor plane never commits.
  hl.env("AQ_NO_ATOMIC", "1")
  hl.config({
    cursor = {
      no_hardware_cursors = true,
    },
  })

  -- Follow the VM window when it is resized, and share the host clipboard.
  hl.exec_cmd(o.launch("omarchy-hw-vmware-display-watch"))
  hl.exec_cmd(o.launch("omarchy-launch-vmware-user"))
  return
end

hl.env("LIBGL_ALWAYS_SOFTWARE", "1")

-- Hyper-V Enhanced Session Mode: VMConnect attaches to an RDP server that
-- shares this session over vsock. Set up by dedsec/hyperv.sh; the launcher
-- is a no-op until then.
if hyperv then
  hl.exec_cmd(o.launch("omarchy-launch-hyperv-rdp"))
end
