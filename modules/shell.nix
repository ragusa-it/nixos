# modules/shell.nix
# Fish shell configuration with plugins and aliases
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # FISH SHELL
  # ═══════════════════════════════════════════════════════════════
  programs.fish = {
    enable = true;

    # Interactive shell init (equivalent to config.fish)
    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Ghostty shell integration
      if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
      end

      # Pure prompt configuration
      set -g pure_show_system_time false
      set -g pure_enable_single_line_prompt true

      # Key bindings (vi mode optional)
      # fish_vi_key_bindings

      # Better directory navigation
      set -g fish_prompt_pwd_dir_length 3
    '';

    # ═══════════════════════════════════════════════════════════════
    # ALIASES
    # ═══════════════════════════════════════════════════════════════
    shellAliases = {
      # ─── Modern Replacements ───
      ll = "eza -la --icons --git";
      ls = "eza --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons --level=2";
      cat = "bat";
      find = "fd";
      grep = "rg";
      df = "duf";
      du = "dust";
      sed = "sd";

      # ─── Docker ───
      dc = "docker compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      dl = "docker logs -f";
      dex = "docker exec -it";

      # ─── Git ───
      gs = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --oneline -20";
      glo = "git log --oneline --graph --all";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpu = "git pull";
      gco = "git checkout";
      gb = "git branch";
      gst = "git stash";

      # ─── NixOS ───
      rebuild = "sudo nixos-rebuild switch --flake .";
      rebuild-boot = "sudo nixos-rebuild boot --flake .";
      rebuild-test = "sudo nixos-rebuild test --flake .";
      update = "nix flake update";
      search = "nix search nixpkgs";
      gc-nix = "sudo nix-collect-garbage -d";

      # User profile (GUI apps, fast-updating tools)
      update-apps = "nix profile upgrade '.*'";
      list-apps = "nix profile list";

      # ─── System ───
      ports = "ss -tulanp";
      myip = "curl -s ifconfig.me";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # ─── Safety ───
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };

    # ═══════════════════════════════════════════════════════════════
    # ABBREVIATIONS
    # ═══════════════════════════════════════════════════════════════
    # Expand on space, more flexible than aliases
    shellAbbrs = {
      g = "git";
      d = "docker";
      n = "nix";
      v = "nvim";
      c = "code";
      z = "zed";
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # PLUGINS & PACKAGES
  # ═══════════════════════════════════════════════════════════════
  # Fish plugins (managed by NixOS)
  environment.systemPackages = with pkgs; [
    # Fish plugins
    fishPlugins.pure # Pure prompt (minimal & fast)
    fishPlugins.autopair # Auto-close brackets, quotes
    fishPlugins.fzf-fish # Fzf integration for fish
    fishPlugins.done # Notification when long command finishes
    fishPlugins.grc # Colorize command output

    # Required by plugins/aliases
    grc # Required by fishPlugins.grc
    dust # Better du
  ];
}
