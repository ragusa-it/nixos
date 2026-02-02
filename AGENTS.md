# AGENTS.md - NixOS Configuration Repository

## 1. Project Context
This is a **NixOS Flake configuration** for a personal desktop system (hostname: `nix`, user: `pinj`).
It relies on modern Nix features (Flakes, experimental commands) and a modular architecture.

## 2. Build & Validation Commands

### Core Workflows
Use these commands to verify your changes. **Always run the test command before asking the user to switch.**

```bash
# 1. SYNTAX CHECK (Fastest)
# Checks for basic syntax errors without evaluating the entire system
nix-instantiate --parse configuration.nix

# 2. FLAKE CHECK (Unit Tests)
# Validates flake structure and evaluates outputs. Use this to ensure no regression.
nix flake check

# 3. DRY RUN (Integration Test)
# Builds the system and tries to activate it in a VM or checks for conflicts 
# without modifying the bootloader or switching the current system.
sudo nixos-rebuild test --flake .#nixos
```

### Deployment
Only run these when explicitly requested by the user:

```bash
# Build (create derivation but don't switch)
sudo nixos-rebuild build --flake .#nixos

# Switch (apply changes to live system)
sudo nixos-rebuild switch --flake .#nixos
```

### Maintenance
```bash
# Update inputs (e.g. nixpkgs)
nix flake update

# Format all nix files
nixfmt *.nix modules/*.nix
```

## 3. Code Style & Conventions

### Visual Structure
Maintain the project's visual hierarchy. Use decorative comments to separate major sections.

```nix
# ═══════════════════════════════════════════════════════════════
# SECTION NAME (UPPERCASE)
# ═══════════════════════════════════════════════════════════════
```

### Nix Formatting
- **Indentation:** 2 spaces.
- **Lists:** Use `with pkgs; [ ... ]` for package lists to reduce verbosity.
- **Line Length:** Soft limit 100 chars, hard limit 120.
- **Functions:** Use standard module arguments: `{ config, pkgs, lib, ... }:`.

### Module Pattern
All functionality should be modularized in `./modules/`.
- **Filename:** `kebab-case.nix` (e.g., `gpu-amd.nix`).
- **Structure:**
  ```nix
  { config, pkgs, lib, ... }: {
    # Options
    programs.foo.enable = true;

    # Packages
    environment.systemPackages = with pkgs; [
      foo-pkg
    ];
  }
  ```

### Naming & Variables
- **Inputs:** Reference flake inputs via `inputs.name` (passed via `specialArgs`).
- **Packages:** Use `pkgs.packageName`.
- **User:** The primary user `pinj` is defined in `configuration.nix`.
- **Groups:** Add user to groups via `extraGroups` in specific modules (e.g., `docker` group in `dev.nix`).

## 4. Agent Guidelines

### ⚠️ Critical Safety Rules
1.  **Secrets:** NEVER commit secrets (tokens, keys, passwords). Check `.gitignore`.
2.  **Hardware Config:** Do NOT modify `hardware-configuration.nix` unless explicitly checking for new drives/mounts. It is auto-generated.
3.  **State Version:** Do NOT change `system.stateVersion` ("26.05").

### Navigation & Editing
- **Absolute Paths:** When using tools, always resolve paths fully (e.g., `/home/pinj/nixos/modules/dev.nix`).
- **Read First:** Always read `configuration.nix` to see active imports before creating new modules.
- **Search:** Use `grep` to find where existing programs are configured (e.g., `grep -r "firefox" .`).

### Troubleshooting Common Errors
- **"Option does not exist":** You might be missing an import in `configuration.nix` or using a home-manager option in a system module.
- **"Hash mismatch":** If updating a `fetchurl` or flake input, ensure hashes are updated.
- **"ReadOnly":** You cannot edit files in the `/nix/store`. Only edit files in `/home/pinj/nixos`.

## 5. Directory Structure

| Path | Purpose |
|------|---------|
| `flake.nix` | Entry point, dependencies (inputs), and outputs. |
| `configuration.nix` | System glue. Imports modules, sets defaults, defines user. |
| `modules/` | Feature-specific configs (desktop, dev, gaming, etc.). |
| `hardware-configuration.nix` | Hardware scan (do not edit manually). |
