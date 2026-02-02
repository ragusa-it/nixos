# atlas - NixOS configuration

Personal NixOS desktop configuration built with **Nix flakes** for x86_64-linux. The setup is modular and targets a Wayland desktop (Niri + Ly) with PipeWire audio, AMD GPU support, and a curated set of apps and developer tooling.

## Highlights

- **Wayland desktop**: Niri compositor, Ly display manager, portals, Polkit agent
- **Audio**: PipeWire (ALSA, PulseAudio, JACK)
- **AMD GPU stack**: Vulkan, VA-API, CoreCtrl
- **Developer tooling**: Docker, Rust, Node.js, Python
- **Extras**: Steam/Gaming, virtualization, theming, Navidrome

## Prerequisites

- A **recent NixOS installer ISO** with flake support
- **x86_64-linux** hardware (this flake is pinned to that system)
- Basic familiarity with the NixOS installation process

> This is a personal configuration. Expect to adjust the hostname, user, and hardware modules for your machine.

## Installation (fresh NixOS install)

1. **Download and boot the NixOS graphical installer**
   - <https://nixos.org/download.html>

2. **Follow the graphical installer**
   - Partition your drives as needed
   - Create your user account
   - When prompted for desktop environment, select **No desktop**
   - Complete the installation

3. **Reboot and log in** to your new shell-only NixOS system

4. **Clone this repository**

   ```sh
   git clone https://github.com/ragusa-it/nixos ~/nixos
   ```

5. **Copy your hardware configuration into the repo**

   ```sh
   cp /etc/nixos/hardware-configuration.nix ~/nixos/hardware-configuration.nix
   ```

6. **Review and customize**

   - `configuration.nix`
     - `networking.hostName`
     - `users.users.pinj` (change username/groups as needed)
   - `modules/gpu-amd.nix` if you are **not** on AMD hardware

7. **Rebuild with the flake**

   ```sh
   sudo nixos-rebuild switch --flake ~/nixos#nixos
   ```

8. **Reboot** to start the full desktop environment

   ```sh
   sudo reboot
   ```

## Post-install rebuilds

From inside the cloned repository:

```sh
sudo nixos-rebuild switch --flake .#nixos
```

Use `boot` if you want to schedule the change for the next reboot:

```sh
sudo nixos-rebuild boot --flake .#nixos
```

## Updating the system

```sh
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

## Repository layout

- `flake.nix` - Flake inputs, binary caches, and system definition
- `configuration.nix` - Main NixOS entry point (imports modules)
- `hardware-configuration.nix` - Machine-specific hardware config (replace on install)
- `modules/` - Modular system features
  - `desktop.nix` - portals, Polkit agent, swaylock, swayidle
  - `gpu-amd.nix` - AMD GPU stack
  - `audio.nix` - PipeWire and Bluetooth
  - `apps.nix` - user applications
  - `dev.nix` - developer tooling
  - `gaming.nix` - Steam, Lutris, Gamemode
  - `theming.nix` - fonts, themes, cursors
  - `virtualization.nix` - QEMU/KVM/virt-manager
  - `power.nix` - power management
  - `shell.nix` - Fish shell configuration
  - `services.nix` - system services (fstrim, zram, avahi)
  - `navidrome.nix` - self-hosted music server

## Troubleshooting

- **Flakes not enabled**: if `nixos-rebuild` fails, prefix the command with `NIX_CONFIG="experimental-features = nix-command flakes"` or enable flakes in `/etc/nix/nix.conf`.
- **Wrong hardware configuration**: regenerate with `sudo nixos-generate-config` and copy the new `hardware-configuration.nix` into the repo.

## License

No license is specified. If you plan to reuse this configuration, please open an issue to discuss licensing.
