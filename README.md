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

# Replace the placeholder hardware-configuration.nix with your actual one
cp /etc/nixos/hardware-configuration.nix hosts/<hostname>/
```

### 2. Replace Placeholders

Edit the following files and replace these placeholders:

| Placeholder | Example Value | Files |
|-------------|---------------|-------|
| `<hostname>` | `desktop` | `flake.nix`, `modules/common.nix` |
| `<username>` | `john` | `modules/common.nix`, `modules/dev.nix`, `modules/gaming.nix` |
| `<timezone>` | `America/New_York` | `modules/common.nix` |
| `<locale>` | `en_US.UTF-8` | `modules/common.nix` |

Also rename `hosts/hostname/` to match your actual hostname.

### 3. Stage Files in Git

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

```bash
# Build and switch to dev config as main system profile
sudo nixos-rebuild switch --flake .#dev

# Build gaming config as separate boot profile
sudo nixos-rebuild boot --profile-name gaming --flake .#gaming
```

### 6. Reboot and Verify

Boot menu should show:
- `NixOS (dev)` - Default boot
- `NixOS (gaming, zen)` - Gaming profile

## Updating

**IMPORTANT:** Always update both profiles together to avoid kernel/Mesa version drift:

```bash
cd ~/nixos-config
git add .
sudo nixos-rebuild switch --flake .#dev
sudo nixos-rebuild boot --profile-name gaming --flake .#gaming
```

To update flake inputs:

```bash
nix flake update
git add flake.lock
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

```bash
passwd
```

### Setup MangoWC

```bash
mkdir -p ~/.config/mango
cp /etc/mango/config.conf ~/.config/mango/config.conf

# Create autostart script
cat > ~/.config/mango/autostart.sh << 'EOF'
#!/bin/bash
qs -c noctalia-shell &
EOF
chmod +x ~/.config/mango/autostart.sh
```

Add to `~/.config/mango/config.conf`:
```
exec-once="~/.config/mango/autostart.sh"
```

### Auto-start MangoWC from TTY

Add to `~/.bash_profile` or `~/.zprofile`:
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