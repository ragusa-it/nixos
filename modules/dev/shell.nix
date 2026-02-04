# modules/dev/shell.nix
# Fish shell with plugins and aliases
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting

      if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
      end

      set -g pure_show_system_time false
      set -g pure_enable_single_line_prompt true
      set -g fish_prompt_pwd_dir_length 3

      clear && fastfetch
    '';

    shellAliases = {
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
      dc = "docker compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      dl = "docker logs -f";
      dex = "docker exec -it";
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
      rebuild = "sudo nixos-rebuild switch --flake .";
      rebuild-boot = "sudo nixos-rebuild boot --flake .";
      rebuild-test = "sudo nixos-rebuild test --flake .";
      update = "nix flake update";
      search = "nix search nixpkgs";
      gc-nix = "sudo nix-collect-garbage -d";
      update-apps = "nix profile upgrade '.*'";
      list-apps = "nix profile list";
      ports = "ss -tulanp";
      myip = "curl -s ifconfig.me";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };

    shellAbbrs = {
      g = "git";
      d = "docker";
      n = "nix";
      v = "nvim";
      c = "code";
      z = "zeditor";
    };
  };

  environment.systemPackages = with pkgs; [
    fishPlugins.pure
    fishPlugins.autopair
    fishPlugins.fzf-fish
    fishPlugins.done
    fishPlugins.grc
    grc
    dust
  ];
}
