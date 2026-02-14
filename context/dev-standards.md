# NixOS Repo Notes (atlas/server/laptop)

This document summarizes the current NixOS configuration repo layout, patterns, and
modules as implemented in `flake.nix`, `hosts/**/configuration.nix`, and `modules/**.nix`.

## Setup Details (What This Config Builds)

- Flake-based multi-host NixOS: `atlas` (desktop), `laptop` (desktop no gaming), `server`
  (headless). See `flake.nix` and `hosts/README.md`.
- Channel: `nixos-unstable` via `inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";`
  in `flake.nix`.
- Kernel: CachyOS kernel via `nix-cachyos-kernel` overlay added in `flake.nix` modules list.
  - Desktop uses `pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3` in
    `modules/core/boot.nix`.
  - Server uses `pkgs.cachyosKernels.linuxPackages-cachyos-server` in
    `modules/core/boot_server.nix`.
- Bootloader: Limine with Secure Boot enabled.
  - `boot.loader.limine.enable = true;`
  - `boot.loader.limine.secureBoot.enable = true;`
  - Wallpaper set to `wallpaper/nix.png`.
- Disk encryption (atlas hardware config currently checked in):
  - Root: LUKS2 `cryptroot` mapped to `/dev/mapper/cryptroot` with XFS (`hosts/atlas/hardware-configuration.nix`).
  - Swap: LUKS2 `cryptswap` with keyfile at `/var/lib/secrets/swap.key` included in initrd.
  - `boot.resumeDevice = "/dev/mapper/cryptswap";` in `modules/core/boot.nix`.
- Boot UX and kernel params:
  - Plymouth enabled (`nixos-bgrt`) and `quiet/splash/loglevel` tuned in `modules/core/boot.nix`.
  - `boot.initrd.systemd.enable = true;`.
- Scheduler tuning: `services.scx.enable = true; services.scx.scheduler = "scx_lavd";`
  in `modules/core/boot.nix` (and `modules/core/boot_server.nix`).
- Nix settings:
  - `nix-command` + `flakes` enabled in `modules/core/system.nix`.
  - Unfree allowed: `nixpkgs.config.allowUnfree = true;`.
  - Auto upgrade weekly + GC daily (delete older than 10d) in `modules/core/system.nix`.
  - `system.stateVersion = "26.05";`.
- Networking defaults (core module):
  - `networking.networkmanager.enable = true;`
  - `services.openssh.enable = true;`
  - `services.tailscale.enable = true;`
  - `networking.hostName = "nix";` (see “Notable Repo Quirks” below).
- Locale:
  - Timezone `Europe/Berlin`
  - Default locale `en_US.UTF-8` with many `de_DE.UTF-8` `LC_*` overrides
  - Console keymap `de-latin1-nodeadkeys`
- Desktop stack (atlas/laptop):
  - Display manager: `ly` via `services.displayManager.ly.enable = true;`
  - Session: `services.displayManager.defaultSession = "niri";`
  - WM/Compositor: `programs.niri.enable = true;` (`modules/desktop/niri.nix`)
  - XDG portals: enabled with GTK portal + polkit agent user service
- Audio: PipeWire + WirePlumber, Bluetooth enabled; Pulseaudio disabled.
- Flatpak: enabled and adds Flathub remote during activation.
- Gaming (atlas):
  - Steam with firewall openings and Proton GE.
  - GameMode with sysctl tuning and `gamescope`.
  - Wine staging + udev rules for game devices.
- Dev tooling:
  - Docker enabled with weekly auto prune.
  - `direnv` + `nix-direnv` enabled.
  - Large CLI/dev package set including `nixd`, `nil`, `nixfmt`, `claude-code`, and `opencode`.

## Repository Structure and Import Graph

- Host entrypoints are under `hosts/<hostname>/configuration.nix`:
  - `hosts/atlas/configuration.nix` imports:
    - `./hardware-configuration.nix`
    - `../../modules/core`
    - `../../modules/hardware`
    - `../../modules/desktop`
    - `../../modules/services`
    - `../../modules/dev`
    - `../../modules/gaming`
  - `hosts/laptop/configuration.nix` imports:
    - core/hardware/desktop/dev plus a subset of services modules
  - `hosts/server/configuration.nix` imports:
    - specific core/hardware modules + `../../modules/dev` + `../../modules/services/maintenance.nix`
    - enables `services.openssh.enable = true;` explicitly (core also enables it)

### Flake Outputs and Host Construction

`flake.nix` defines:

- `specialArgs = { inherit inputs username; };` so modules can reference:
  - `username` for user paths (e.g. `users.users.${username}`; `MusicFolder = "/home/${username}/Music"`).
  - `inputs` for flake packages (e.g. Zen browser, Noctalia shell, Opencode).
- A helper `mkHost hostname = nixpkgs.lib.nixosSystem { ... }` that loads:
  - `./hosts/${hostname}/configuration.nix`
  - an inline module setting `nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];`
- `nixConfig` binary caches:
  - `nix-community` Cachix
  - `attic.xuyh0120.win/lantian`

### Module Categories

`modules/default.nix` aggregates:

- `modules/core/default.nix`
- `modules/hardware/default.nix`
- `modules/desktop/default.nix`
- `modules/services/default.nix`
- `modules/dev/default.nix`
- `modules/gaming/default.nix`

Each category `default.nix` is “imports only” style.

## Configuration Patterns Used

- **Module function signature**:
  - Most modules follow `{ config, pkgs, lib, ... }:` plus `inputs` and/or `username` when needed.
- **Centralized username**:
  - `flake.nix` sets `username = "pinj";` and passes it via `specialArgs`.
- **Accessing packages from flake inputs**:
  - Pattern used in `modules/desktop/apps.nix` and `modules/dev/tools.nix`:
    - `inputs.<name>.packages.${pkgs.stdenv.hostPlatform.system}.default`
- **Overlays**:
  - Global CachyOS kernel overlay is injected from `flake.nix`.
  - Dev category also adds a local overlay:
    - `modules/dev/default.nix` sets `nixpkgs.overlays = [ (import ../../overlays/firebase-tools.nix) ];`
    - `overlays/firebase-tools.nix` forces `firebase-tools` to use `nodejs_22` when available.
- **System packages as the main mechanism**:
  - Many features are enabled by adding to `environment.systemPackages` in the relevant module.
- **Host-specific composition**:
  - “Desktop features” are composed by importing modules; server imports a smaller subset.

## Modules Used (By Category)

### Core (`modules/core/*`)

- `modules/core/boot.nix`
  - Limine boot + Secure Boot, kernel selection, Plymouth, kernel params
  - scx scheduler configuration
- `modules/core/boot_server.nix`
  - Same structure as `boot.nix` but uses `linuxPackages-cachyos-server`
- `modules/core/system.nix`
  - Nix flakes enablement, auto upgrade, GC, allowUnfree, `system.stateVersion`
- `modules/core/networking.nix`
  - NetworkManager, OpenSSH, Tailscale, default hostname
- `modules/core/users.nix`
  - Creates `users.users.${username}` with Fish shell and group memberships
  - Enables Fish and Zsh
- `modules/core/localization.nix`
  - Timezone/locale and console keymap

### Hardware (`modules/hardware/*`)

- `modules/hardware/storage.nix`
  - Mount points for several ext4 SSDs under `/mnt/*` with `nofail` and GVFS visibility
  - Weekly fstrim
  - zram swap enabled (`memoryPercent = 100`, `algorithm = "zstd"`)
- `modules/hardware/audio.nix`
  - PipeWire + WirePlumber config, 32-bit ALSA support, Bluetooth enabled
  - Adds audio utilities (`pavucontrol`, `pwvucontrol`, `playerctl`)
- `modules/hardware/gpu-amd.nix`
  - AMD graphics stack, 32-bit support, VA-API/VDPAU helpers, ROCm ICD
  - CoreCtrl + AMD overdrive
- `modules/hardware/power.nix`
  - power-profiles-daemon + CPU governor

### Desktop (`modules/desktop/*`)

- `modules/desktop/niri.nix`
  - Enables X server, `ly` display manager, default session `niri`, XKB layout
- `modules/desktop/portals.nix`
  - XDG portal (GTK), polkit enabled + user `polkit-gnome-agent` systemd service
  - Wayland-related env vars and utilities
- `modules/desktop/theming.nix`
  - Font packages + fontconfig defaults, gtk/qt theming utilities
- `modules/desktop/apps.nix`
  - GUI app set
  - Installs Zen browser via flake input
  - Installs Noctalia shell via flake input
  - Enables Flatpak + adds Flathub remote in activation script
  - Enables GNOME keyring, `programs.yazi`, and `programs.firefox`

### Services (`modules/services/*`)

- `modules/services/avahi.nix`
  - Avahi mDNS publishing + firewall openings
- `modules/services/printing.nix`
  - CUPS printing
- `modules/services/maintenance.nix`
  - `psd`, `fwupd`, `earlyoom`, `plocate` periodic indexing
- `modules/services/navidrome.nix`
  - Local-only Navidrome on `127.0.0.1:4533` with `MusicFolder=/home/${username}/Music`
  - Ensures `~/Music` exists via tmpfiles

### Development (`modules/dev/*`)

- `modules/dev/docker.nix`
  - Docker enabled + weekly auto prune; includes `docker-compose` and `lazydocker`
- `modules/dev/shell.nix`
  - Fish prompt and shell init (Ghostty integration if present), lots of aliases/abbrs
  - Fish plugins and CLI QoL tools
- `modules/dev/tools.nix`
  - Toolchains and CLIs (node/python/rustup, compilers, nix tooling, cloud CLIs, AI tools)
  - Installs Opencode via flake input

### Gaming (`modules/gaming/*`)

- `modules/gaming/steam.nix`
  - Steam enabled, firewall exceptions, Proton GE, steam hardware udev rules
- `modules/gaming/gamemode.nix`
  - GameMode enabled with renice + AMD perf-level config
  - Sysctl tuning for gaming workloads
  - Includes `gamemode` and `gamescope`
- `modules/gaming/wine.nix`
  - Wine staging + helpers; controller udev rules

## Operational Commands (Repo-Local)

- Evaluate and validate:
  - `nix flake check`
- Build without activating:
  - `sudo nixos-rebuild dry-build --flake .#atlas`
  - `sudo nixos-rebuild dry-build --flake .#laptop`
  - `sudo nixos-rebuild dry-build --flake .#server`
- Activate (on target machine):
  - `sudo nixos-rebuild switch --flake .#atlas` (or `#laptop`, `#server`)
- Format:
  - `nixfmt **/*.nix`

## Notable Repo Quirks / Potential Follow-Ups

- `modules/core/networking.nix` sets `networking.hostName = "nix";` which will apply to all
  hosts unless overridden elsewhere (host configs currently comment about setting hostname).
- `scripts/setup-secureboot.sh` and `scripts/install-fde.sh` reference `#nixos` in their
  example commands, but `flake.nix` defines `#atlas`, `#server`, and `#laptop`.
- `modules/core/boot_server.nix` file header comment says `modules/core/boot.nix` (cosmetic).
- `hosts/server/hardware-configuration.nix` and `hosts/laptop/hardware-configuration.nix`
  are identical to `hosts/atlas/hardware-configuration.nix` in this repo snapshot (likely placeholders).

