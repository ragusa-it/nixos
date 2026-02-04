# 🐧 Atlas - NixOS Configuration

A modular, flake-based NixOS configuration for a desktop workstation optimized for gaming, development, and daily use.

## ✨ Features

- **🎮 Gaming-Ready**: Steam with Proton-GE, Lutris, Heroic, Faugus Launcher, Gamemode with AMD GPU optimizations
- **🖥️ Wayland-Native**: Niri compositor with Noctalia shell and modern Wayland tooling
- **⚡ Performance**: CachyOS kernel (x86_64-v3) with scx_lavd scheduler for low-latency gaming
- **🛠️ Development**: Docker, Node.js 22, Rust (rustup), Python 3, Bun, and modern CLI tools
- **🎨 Theming**: Adwaita dark theme, Papirus icons, JetBrains Mono & Inter fonts
- **🎵 Media**: Navidrome music server, PipeWire audio with JACK support, full Bluetooth codec support
- **🔒 Security**: Secure Boot with Limine bootloader

## 📁 Structure

```
nixos/
├── flake.nix                 # Flake definition with inputs
├── flake.lock                # Locked dependencies
├── configuration.nix         # Main config (boot, networking, user, localization)
├── hardware-configuration.nix # Auto-generated hardware config (don't edit)
└── modules/
    ├── apps.nix              # User applications (media, productivity, communication)
    ├── audio.nix             # PipeWire, Bluetooth codecs, audio controls
    ├── desktop.nix           # Wayland, XDG portals, polkit, Vicinae launcher
    ├── dev.nix               # Docker, languages, build tools, CLI utilities
    ├── gaming.nix            # Steam, Gamemode, launchers, Wine/Proton
    ├── gpu-amd.nix           # AMD drivers, Vulkan, VA-API, CoreCtrl
    ├── navidrome.nix         # Music streaming server
    ├── power.nix             # Power profiles daemon, CPU governor
    ├── services.nix          # System services (fstrim, zram, avahi, psd, earlyoom)
    ├── shell.nix             # Fish shell config with plugins and aliases
    └── theming.nix           # Fonts, GTK/Qt themes, cursors, dconf
```

## 🚀 Flake Inputs

| Input | Description |
|-------|-------------|
| `nixpkgs` | NixOS unstable channel |
| `nix-cachyos-kernel` | CachyOS optimized kernel with x86_64-v3 |
| `noctalia` | Noctalia desktop shell |
| `zen-browser` | Zen Browser (Firefox-based) |
| `opencode` | OpenCode AI coding assistant |

## 📦 Installation

### Prerequisites

- NixOS installed with flakes enabled
- AMD CPU and GPU (configuration includes AMD-specific optimizations)
- UEFI system (for Secure Boot support)

### Steps

1. **Clone this repository:**
   ```bash
   git clone https://github.com/ragusa-it/nixos.git /etc/nixos
   ```

2. **Generate hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
   ```

3. **Update the configuration:**
   - In `flake.nix`: Change `username = "pinj"` to your username
   - In `configuration.nix`:
     - Update `networking.hostName` if desired
     - Adjust `time.timeZone` (currently "Europe/Berlin")
     - Review and adjust locale settings
     - Update secondary storage mount points or remove them
     - Review keyboard layout (currently German)

4. **Rebuild the system:**
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

5. **(Optional) Set up Secure Boot:**
   ```bash
   sudo sbctl create-keys
   sudo sbctl enroll-keys -m
   ```

6. **Flatpak is auto-configured** - Flathub repository is automatically added on system activation

## 🔧 Usage

### Rebuild System

```bash
# Test configuration without switching
sudo nixos-rebuild test --flake .#nixos

# Switch to new configuration
sudo nixos-rebuild switch --flake .#nixos

# Build and set as boot default (without switching)
sudo nixos-rebuild boot --flake .#nixos
```

### Update Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

### Search and Install Packages

```bash
# Search for packages
nix search nixpkgs <package-name>

# Aliases available in Fish shell
search <package-name>  # Same as above
```

### Garbage Collection

Automatic garbage collection is configured weekly, but you can run it manually:

```bash
# Collect garbage older than 14 days
sudo nix-collect-garbage --delete-older-than 14d

# Optimize store
nix-store --optimise
```

## 🖥️ Desktop Environment

- **Compositor**: Niri (scrollable tiling Wayland compositor)
- **Display Manager**: Ly
- **Terminal**: Ghostty
- **Browser**: Zen Browser (primary), Firefox
- **File Manager**: Nautilus (GNOME Files)
- **Editors**: Zed Editor, Claude Code, OpenCode

## 🎮 Gaming

The gaming module provides:

- **Steam** with Proton-GE for enhanced Windows game compatibility
- **Gamemode** for automatic CPU/GPU performance optimizations
- **Game Launchers**: Lutris, Heroic (Epic/GOG), Faugus Launcher
- **Wine Support**: Wine Staging with Winetricks and Protontricks
- **Gamescope** micro-compositor for fixing problematic games
- **Kernel Tweaks**: Increased inotify watchers, optimized swap settings

### AMD GPU Optimizations

- **CoreCtrl** for fan curves, overclocking, and GPU monitoring
- Full power management features enabled (`amdgpu.ppfeaturemask=0xffffffff`)
- **RADV** (Mesa Vulkan) driver - best for gaming
- **VA-API** hardware video acceleration (decode/encode)
- **Monitoring Tools**: radeontop, nvtop (AMD edition)
- **Vulkan Tools**: vulkan-tools, vulkan-loader for debugging

## 🛠️ Development

Included tools:

- **Languages**: Node.js 22, Python 3, Rust (via rustup), Bun
- **Containers**: Docker with weekly auto-prune, Docker Compose
- **Environment Management**: direnv with nix-direnv for per-project environments
- **Build Tools**: gcc, gnumake, cmake, pkg-config
- **Version Control**: git, gh (GitHub CLI), delta (better diffs), lazygit
- **CLI Utilities**: 
  - Search: ripgrep, fd, fzf
  - Files: eza, bat, broot
  - Data: jq, yq
  - System: duf, dust, pv, parallel
  - Text: sd (better sed), tealdeer (tldr)
- **Editors**: Zed Editor, micro, Claude Code, OpenCode
- **Nix Tools**: nil (LSP), nixd, nixfmt (formatter)
- **Package Manager**: pnpm (for Node.js)

## 🎵 Audio & Media

- **Audio Stack**: PipeWire with ALSA, PulseAudio, and JACK support
- **Volume Control**: pwvucontrol (Qt/PipeWire), pavucontrol (GTK/fallback)
- **Media Control**: playerctl for media keys and D-Bus control
- **Bluetooth**: Full codec support (LDAC, AAC, aptX HD, aptX, SBC-XQ)
- **Music Server**: Navidrome (localhost:4533) with Last.fm scrobbling
- **Music Tools**: Feishin (client), Picard (tagger), beets (library manager), cava (visualizer)
- **Video Players**: MPV, Celluloid (MPV GUI), VLC
- **Screen Recording**: OBS Studio, GPU Screen Recorder, Swappy (annotation)

## ⚙️ Key Services

| Service | Description |
|---------|-------------|
| **Tailscale** | Mesh VPN for secure remote access |
| **OpenSSH** | Remote shell access |
| **Navidrome** | Music streaming server (port 4533) |
| **Avahi** | mDNS for .local network discovery |
| **Profile-sync-daemon** | Browser profiles in tmpfs for faster performance |
| **ZRAM** | Compressed swap in RAM (zstd, 100% memory) |
| **fstrim** | Weekly SSD TRIM for longevity |
| **earlyoom** | Prevent system freeze on low memory |
| **plocate** | Fast file search database (daily updates) |
| **fwupd** | Firmware updates |
| **scx_lavd** | Low-latency scheduler for gaming |

## 📦 Package Management

All packages in this configuration are installed as system packages (`environment.systemPackages`) across different modules. This provides:

- **Unified Management**: All packages updated together during system rebuild
- **Reproducibility**: Entire system configuration in one place
- **No Profile Conflicts**: Avoid nix profile state issues

### Package Categories

| Category | Module | Examples |
|----------|--------|----------|
| **Desktop Core** | configuration.nix, desktop.nix | Nautilus, Ghostty, Zen Browser, Noctalia, wl-clipboard |
| **Applications** | apps.nix | Vesktop, Thunderbird, Signal, Telegram, Obsidian, OnlyOffice |
| **Media** | apps.nix | Loupe, Evince, MPV, Celluloid, VLC, Feishin, Picard, OBS |
| **Development** | dev.nix | Docker, Node.js, Rust, Python, Bun, git, lazygit, CLI tools |
| **Gaming** | gaming.nix | Steam, Lutris, Heroic, Faugus Launcher, Wine, Gamescope |
| **System Tools** | apps.nix | btop, Mission Center, Bitwarden, file-roller, disk utility |
| **GPU** | gpu-amd.nix | CoreCtrl, radeontop, nvtop, Vulkan tools |
| **Shell** | shell.nix | Fish plugins (pure, autopair, fzf-fish, done, grc) |
| **Theming** | theming.nix | Fonts (JetBrains Mono, Inter, Noto), themes (adw-gtk3), icons (Papirus) |

### Adding Packages

To add a new package:
1. Identify the appropriate module (e.g., apps.nix for GUI apps, dev.nix for dev tools)
2. Add the package to the `environment.systemPackages` list
3. Run `sudo nixos-rebuild switch --flake .#nixos`

## 📝 Notes

### System Details
- **Kernel**: CachyOS latest with x86_64-v3 optimizations
- **Bootloader**: Limine with Secure Boot support
- **Scheduler**: scx_lavd (low-latency scheduler optimized for gaming)
- **Shell**: Fish (default), Zsh (available as fallback)
- **Display Manager**: Ly (TUI)
- **Compositor**: Niri with Noctalia shell
- **User**: `pinj` (Melvin Ragusa)
- **Hostname**: `nix`
- **Timezone**: Europe/Berlin (German locale with English UI)
- **Keyboard**: German (de-latin1-nodeadkeys)

### Configuration Features
- **Unfree Packages**: Enabled globally
- **Flakes**: Enabled with nix-command
- **Binary Caches**: nix-community, lantian (CachyOS)
- **Auto-Optimization**: Store optimization enabled
- **Garbage Collection**: Weekly, keeping 14 days
- **State Version**: 26.05
- **Hibernation**: Configured with encrypted swap (`/dev/mapper/cryptswap`)
- **Flatpak**: Enabled with auto-configured Flathub repository

### Secondary Storage
Three additional SSDs mounted at:
- `/mnt/Intenso-SSD`
- `/mnt/Samsung-SSD`
- `/mnt/Extern-SSD`

### Fish Shell Aliases
Common aliases configured in `shell.nix`:
- `rebuild`, `rebuild-boot`, `rebuild-test` - NixOS rebuild commands
- `update` - Update flake inputs
- `gc-nix` - Run garbage collection
- `ll`, `ls`, `la`, `lt` - eza file listings
- `dc`, `dps`, `dl` - Docker shortcuts
- `gs`, `gd`, `gl`, `gp` - Git shortcuts

## 📄 License

This configuration is provided as-is for personal use and reference.
