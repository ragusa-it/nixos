## Migration Complete
All config files have been updated. Here's your deployment plan:
### Step 1: Rebuild your system
```bash
sudo nixos-rebuild switch --flake .#nixos
```
### Step 2: Install user packages to your profile
```bash
nix profile install github:youwen5/zen-browser-flake
nix profile install github:anomalyco/opencode
nix profile install nixpkgs#claude-code
nix profile install nixpkgs#zed-editor
nix profile install nixpkgs#fastfetch
nix profile install nixpkgs#loupe nixpkgs#evince nixpkgs#celluloid nixpkgs#mpv
nix profile install nixpkgs#amberol nixpkgs#feishin nixpkgs#picard nixpkgs#beets nixpkgs#cava
nix profile install nixpkgs#vesktop nixpkgs#thunderbird nixpkgs#signal-desktop nixpkgs#telegram-desktop
nix profile install nixpkgs#libreoffice-fresh nixpkgs#obsidian
nix profile install nixpkgs#btop nixpkgs#mission-center nixpkgs#gnome-calculator nixpkgs#gnome-clocks nixpkgs#baobab nixpkgs#localsend nixpkgs#meld nixpkgs#bitwarden-desktop
nix profile install nixpkgs#swappy nixpkgs#obs-studio nixpkgs#gpu-screen-recorder nixpkgs#kooha
nix profile install nixpkgs#lazygit nixpkgs#lazydocker nixpkgs#dbeaver-bin nixpkgs#httpie nixpkgs#curlie nixpkgs#glances nixpkgs#inxi
nix profile install nixpkgs#lutris nixpkgs#heroic nixpkgs#protonup-qt
```
