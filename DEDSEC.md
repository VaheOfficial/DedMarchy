# DedSecOS

A Watch Dogs-inspired layer on top of [Omarchy 4](https://omarchy.org): neon green, electric cyan, near-black backgrounds, and a surveillance-console feel. Fork of [omacom/omarchy](https://github.com/omacom/omarchy) tracking the 4.x line.

**Repo:** `VaheOfficial/DedMarchy`
**Base:** Omarchy 4 (Arch Linux, Hyprland, Quickshell)
**Checkout:** `~/omarchy`, linked through Omarchy's dev channel

---

## How it fits into Omarchy 4

Omarchy 4 ships as two pacman packages installed by the ISO, with the runtime tree at `/usr/share/omarchy`. DedSec does not replace those packages. It uses Omarchy's own dev channel: `omarchy-dev-link` points `$OMARCHY_PATH` at a git checkout, and from then on the commands in `bin/`, the Quickshell desktop in `shell/`, the themes, the Hyprland defaults, and the migrations all come from that checkout while packages keep coming from Omarchy's repositories. `omarchy update` pulls the checkout (fast-forward) and updates the packages in one go.

Everything DedSec adds lives in this repo on top of upstream 4, so upstream can be merged in as it moves.

## Installation

1. Install Omarchy 4 from the ISO and boot into the desktop.
2. Open a terminal and run the bootstrap:

```bash
bash <(curl -sL https://raw.githubusercontent.com/VaheOfficial/DedMarchy/dev/dedsec.sh)
```

Add `--blackarch` to install the curated BlackArch tool groups (about 1,900 packages, 22 GB installed plus an 8 GB download cache). The full 2,800-tool set is only offered afterwards, from the menu.

The bootstrap clones the fork into `~/omarchy`, links Omarchy to it, and runs `dedsec/setup.sh`, which is safe to re-run:

| Step | What it does |
|------|--------------|
| Packages | `greetd`, `quickshell`, `rustscan` |
| Theme | `omarchy-theme-set dedsec` |
| Branding | DedSec logo as the screensaver and About art |
| Shell prompt | DedSec Starship prompt |
| Menu | DedSec rows in the Omarchy menu (see below) |
| Desktop HUD | eww overlay with node info, log feed, diagnostics |
| VM support | Software rendering for the whole session inside VMware, VirtualBox, or Hyper-V, plus guest tools |
| Login screen | greetd with the DedSec Quickshell greeter, replacing SDDM |
| Boot splash | DedSec Plymouth theme published from the checkout |

Environment overrides: `DEDSEC_REPO`, `DEDSEC_REF`, `DEDSEC_CHECKOUT`.

### Virtual machines

Run the bootstrap inside the VM after the ISO install. On VMware, VirtualBox, and Hyper-V the setup writes `LIBGL_ALWAYS_SOFTWARE=1` to `/etc/environment.d/10-dedsec-vm.conf` so the compositor, the shell, and every app render on the CPU through one path, which is what keeps VMware's half-working virtual GPU from wedging the session. The greeter is launched with the same flag. VMware also gets `open-vm-tools`; Hyper-V gets the `hyperv` integration daemons. `E:\Hyper-VOmarchy\OmarchySetup.ps1` creates a ready-made Hyper-V VM on Windows.

---

## What DedSec changes

### Theme (`themes/dedsec/`)

| Role | Color | Hex |
|------|-------|-----|
| Accent | Neon Green | `#00FF41` |
| Cyan | Electric Cyan | `#00E5FF` |
| Foreground | Pale Teal | `#B0F4E6` |
| Background | Near-Black | `#050A0E` |
| Surface | Dark Blue | `#0A1018` |
| Muted | Slate | `#1E3044` |
| Alert | Hot Magenta | `#FF2D6F` |
| Cursor | Bright Teal | `#C8FFF4` |

`colors.toml` drives everything Omarchy generates from a theme: terminal, btop, Chromium, the Omarchy shell (bar, menu, notifications, OSD, lock screen), Neovim, Helix, VS Code. `hyprland.lua` adds the green-to-cyan active border and slightly translucent terminals. Backgrounds, btop, Neovim, and VS Code files are shipped directly.

### Hyprland look and feel (`default/hypr/looknfeel.lua`)

Dense and fast: 2/4 px gaps, sharp corners, green-tinted shadows, blur on, JetBrainsMono group bars, snappy bezier animations with sliding workspaces. User overrides go in `~/.config/hypr/looknfeel.lua` as in stock Omarchy.

### Menu (`config/omarchy/extensions/omarchy-menu.jsonc`)

Omarchy's menu is a shell plugin extended through a JSONC file, so DedSec adds rows rather than replacing the menu:

| Entry | Description |
|-------|-------------|
| Learn > DedSec | This document |
| Setup > App Visibility | Hide or show apps in the launcher (`omarchy-cmd-hide-manager`) |
| Tools | BlackArch groups: Recon, Scanner, Exploitation, Web App, Cracker, Wireless, Sniffer, Proxy, Forensic, Social, Fuzzer, plus Install All |

Each Tools entry runs `omarchy-blackarch-tools <group>`, which offers to enable the repository, lists the installed tools of that group for launching, or installs the group if none are present.

### Login screen (`default/dedsec-greeter/`)

A Quickshell greeter run by greetd inside a minimal Hyprland session (`Greeter/examples/greeter.hyprland.lua`, launched through `start-hyprland`). Animated splash, operator identity card derived from the machine id, system status panel, terminal-style log, custom password field. Deployed to `/opt/dedsec` by `dedsec/greetd.sh`; `omarchy-refresh-greeter` re-deploys it and rewrites the greetd session. Falls back to SDDM if Quickshell is missing. The lock screen is Omarchy 4's own shell lock, themed by the DedSec colors.

The launcher `default/dedsec-greeter/launch-greeter.sh` logs to `/tmp/dedsec-greeter-<user>.log` and falls back to software rendering if the first attempt dies.

### Boot splash (`default/plymouth/`)

Omarchy's boot flow (eased fake progress, drive-decryption prompt) with a DedSec console readout under the logo: six boot lines typed out behind a scrambling cursor, finished lines dimmed, a blinking block cursor on the latest line, and a thin neon progress line. `omarchy-refresh-plymouth` publishes it from the checkout.

### Desktop HUD (`config/eww/`)

| Position | Widget | Update |
|----------|--------|--------|
| Top-right | `ENV // hostname`, `NODE // ip` | 60s / 10s |
| Bottom-left | System log feed | 5s |
| Bottom-right | Kernel, uptime | 1h / 30s |
| Center | DedSec watermark | static |

Started with the session from `default/hypr/autostart.lua` when eww is installed.

### Commands added to `bin/`

| Command | Purpose |
|---------|---------|
| `omarchy-blackarch-tools` | Browse, launch, or install a BlackArch group |
| `omarchy-install-blackarch` | Interactive picker for any BlackArch group or the full set |
| `omarchy-cmd-hide-manager` | Hide or show apps in the launcher |
| `omarchy-tui-list`, `omarchy-tui-show` | Inspect installed TUI shortcuts |
| `omarchy-refresh-greeter` | Re-deploy the greeter and greetd session |
| `omarchy-hw-vm`, `omarchy-hw-vmware` | VM detection helpers |
| `omarchy-dev-generate-logos` | Regenerate branding assets |

`omarchy-pkg-add` passes `--overwrite '*' --ask 4` so non-interactive installs never stop on a file already on disk or a "remove conflicting package?" prompt.

---

## Layout

```
DedMarchy/
  dedsec.sh               # Bootstrap: clone, dev-link, setup
  dedsec/                 # Setup steps: setup.sh, greetd.sh, eww.sh, vm.sh, vmware.sh, blackarch-*.sh
  bin/                    # Omarchy commands plus the DedSec ones above
  shell/                  # Omarchy 4 Quickshell desktop (unchanged)
  default/
    hypr/                 # Hyprland defaults (DedSec looknfeel.lua, vm.lua)
    dedsec-greeter/       # Quickshell greeter project
    plymouth/             # DedSec boot splash
    eww/scripts/          # HUD helpers
  config/
    omarchy/extensions/   # Menu rows
    eww/                  # HUD widgets
    starship.toml         # Prompt
  themes/dedsec/          # The theme
  DEDSEC.md
```

## Development

The dev environment is Windows. `.gitattributes` forces LF line endings, and `dedsec.sh` restores executable bits on the scripts after cloning.

Keeping up with upstream: `git fetch upstream` and merge the tag or branch you want; DedSec's additions are isolated under `dedsec/`, `default/dedsec-greeter/`, `themes/dedsec/`, `config/eww/`, the menu extension, and a handful of `bin/` commands, with value-only edits in `default/hypr/looknfeel.lua`, `default/plymouth/`, and `bin/omarchy-pkg-add`.
