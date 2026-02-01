# NixOS Dual-Configuration Setup

A NixOS system with **two fully isolated configurations**:

1. **Dev** - Latest stable kernel, web development tooling (Docker, Node.js, direnv)
2. **Gaming** - Zen kernel, Steam, Lutris, performance tools

Both share a common base: MangoWC (Wayland compositor) + Noctalia Shell, AMD RDNA 4 GPU support, and a shared `/home` directory with mutable dotfiles.

## Target Hardware

| Component | Model | Notes |
|-----------|-------|-------|
| CPU | AMD Ryzen 7 5700G | Zen 3, iGPU available |
| GPU | AMD RX 9060 XT | RDNA 4, requires Kernel 6.14+, Mesa 25.0+ |
| Motherboard | MSI B550 Tomahawk | Excellent IOMMU groups |

## Directory Structure

```
nixos-config/
├── flake.nix                           # Main flake definition
├── flake.lock                          # Auto-generated after first build
├── hosts/
│   └── <hostname>/
│       └── hardware-configuration.nix  # Copy from /etc/nixos/
└── modules/
    ├── common.nix                      # Shared configuration
    ├── dev.nix                         # Development profile
    └── gaming.nix                      # Gaming profile
```

## Prerequisites

1. NixOS installed (minimal install is fine)
2. Flakes enabled in existing config or via: `nix-shell -p nixFlakes`
3. Know your hostname, username, timezone, and locale

## Quick Setup

### 1. Clone and Prepare

```bash
# Clone this repo to your config directory
git clone <this-repo> ~/nixos-config
cd ~/nixos-config

# Create the host directory (replace <hostname> with your actual hostname)
mkdir -p hosts/<hostname>

# Replace the placeholder hardware-configuration.nix with your actual one
cp /etc/nixos/hardware-configuration.nix hosts/<hostname>/
```

### 2. Review Configuration Defaults

Defaults are set in `flake.nix` and used across modules. Update them there:

| Setting | Example Value | File |
|---------|---------------|------|
| `hostname` | `desktop` | `flake.nix` |
| `username` | `john` | `flake.nix` |
| `time.timeZone` | `America/New_York` | `modules/common.nix` |
| `i18n.defaultLocale` | `en_US.UTF-8` | `modules/common.nix` |

Rename the default `hosts/atlas/` directory to match your hostname (e.g., `hosts/desktop/`), then update the `hostname` value in `flake.nix` to match. The flake uses it to locate `hosts/<hostname>/hardware-configuration.nix`.

### 3. Stage Files in Git

**IMPORTANT:** Flakes require all files to be tracked by git before building.

```bash
cd ~/nixos-config
git add .
```

### 4. Verify Flake

```bash
nix flake check
nix flake show
```

### 5. Build and Switch

**IMPORTANT:** Ensure all files are staged in git (step 3) before building.

```bash
# Build and switch to dev config as main system profile
sudo nixos-rebuild switch --flake .#dev

# (Optional) Test gaming config without committing it as a boot option
sudo nixos-rebuild test --flake .#gaming

# Build gaming config as separate boot profile (available after next reboot)
sudo nixos-rebuild boot --profile-name gaming --flake .#gaming
```

### 6. Reboot and Verify

Boot menu should show:
- `NixOS (dev)` - Default boot
- `NixOS (gaming, zen)` - Gaming profile

## Updating

**IMPORTANT:** Always update both profiles together to avoid kernel/Mesa version drift.

### After Configuration Changes

```bash
cd ~/nixos-config
git add .  # Stage your configuration changes
sudo nixos-rebuild switch --flake .#dev
sudo nixos-rebuild boot --profile-name gaming --flake .#gaming
```

### Updating Flake Inputs Only

```bash
nix flake update
git add flake.lock  # Only stage the lock file, not other changes
sudo nixos-rebuild switch --flake .#dev
sudo nixos-rebuild boot --profile-name gaming --flake .#gaming
```

## Configuration Summary

| Config | Kernel | Key Features |
|--------|--------|--------------|
| `dev` | Latest | Docker, Node.js, direnv, dev CLI tools |
| `gaming` | Zen | Steam, Lutris, MangoHUD, Gamemode, CoreCtrl |
| **Shared** | - | MangoWC, Noctalia, AMD GPU, PipeWire, Firefox |

## Post-Installation

### Change Password

Generate a password hash and save it to `/etc/nixos/secrets/<username>/password.hash` (required before applying the config):
```bash
sudo mkdir -p /etc/nixos/secrets/<username>
sudo chmod 700 /etc/nixos/secrets/<username>
mkpasswd -m sha-512 | sudo tee /etc/nixos/secrets/<username>/password.hash
sudo chmod 600 /etc/nixos/secrets/<username>/password.hash
```

### Setup MangoWC

MangoWC is configured to auto-start via greetd. To customize it:

```bash
mkdir -p ~/.config/mango
cp /etc/mango/config.conf ~/.config/mango/config.conf

# Create autostart script for Noctalia shell
cat > ~/.config/mango/autostart.sh << 'EOF'
#!/bin/bash
# Ensure quickshell is in PATH (it should be as a user package)
qs -c noctalia-shell &
EOF
chmod +x ~/.config/mango/autostart.sh
```

Add to `~/.config/mango/config.conf`:
```
exec-once="~/.config/mango/autostart.sh"
```

### Dev Profile: Docker Access

After switching to the dev profile for the first time, you must log out and log back in (or reboot) for Docker group membership to take effect.

### Auto-start MangoWC from TTY (Alternative)

If not using greetd, add to `~/.bash_profile` or `~/.zprofile`:
```bash
if [[ -z $WAYLAND_DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec mango
fi
```

## GPU Verification

```bash
# Verify firmware loaded
dmesg | grep -i "amdgpu" | grep -i "firmware"

# Check GPU detected
lspci | grep VGA

# Verify Vulkan
vulkaninfo | head -30

# Check ray tracing support
vulkaninfo | grep VK_KHR_ray_tracing_pipeline

# Verify OpenCL
clinfo | head -20
```

## Troubleshooting

### Flake can't find files
```bash
git add .  # Flakes require files to be tracked by git
```

### MangoWC doesn't start
```bash
systemctl status seatd
groups  # Ensure user is in 'seat' group
```

### RDNA 4 black screen
```bash
dmesg | grep -i "amdgpu" | grep -i "firmware"
uname -r  # Should be 6.14+
```

### Steam doesn't launch
Ensure `hardware.graphics.enable32Bit = true;` in common.nix.

### Games won't launch
```bash
cat /proc/sys/vm/max_map_count  # Should be 2147483642 on gaming profile
```

## License

MIT
