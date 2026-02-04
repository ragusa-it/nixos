# modules/limine-custom-labels.nix
# Custom Limine bootloader module with modified entry labels
# Shows kernel version in boot entries: "Linux X.Y.Z-cachyos - Generation N"
# Removes "default profile" from group name

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.boot.loader.limine;
  efi = config.boot.loader.efi;

  # Patched install script that shows kernel version in labels
  limineInstallPatched = pkgs.replaceVarsWith {
    src = ../overlays/limine-install-patched.py;
    isExecutable = true;
    replacements = {
      python3 = pkgs.python3.withPackages (python-packages: [ python-packages.psutil ]);
      configPath = pkgs.writeText "limine-install.json" (
        builtins.toJSON {
          nixPath = config.nix.package;
          efiBootMgrPath = pkgs.efibootmgr;
          liminePath = cfg.package;
          efiMountPoint = efi.efiSysMountPoint;
          fileSystems = config.fileSystems;
          luksDevices = builtins.attrNames config.boot.initrd.luks.devices;
          canTouchEfiVariables = efi.canTouchEfiVariables;
          efiSupport = cfg.efiSupport;
          efiRemovable = cfg.efiInstallAsRemovable;
          secureBoot = cfg.secureBoot;
          biosSupport = cfg.biosSupport;
          biosDevice = cfg.biosDevice;
          partitionIndex = cfg.partitionIndex;
          force = cfg.force;
          enrollConfig = cfg.enrollConfig;
          style = cfg.style;
          resolution = cfg.resolution;
          maxGenerations = if cfg.maxGenerations == null then 0 else cfg.maxGenerations;
          hostArchitecture = pkgs.stdenv.hostPlatform.parsed.cpu;
          timeout = if config.boot.loader.timeout != null then config.boot.loader.timeout else 10;
          enableEditor = cfg.enableEditor;
          extraConfig = cfg.extraConfig;
          extraEntries = cfg.extraEntries;
          additionalFiles = cfg.additionalFiles;
          validateChecksums = cfg.validateChecksums;
          panicOnChecksumMismatch = cfg.panicOnChecksumMismatch;
        }
      );
    };
  };
in

{
  # Only override the installBootLoader when limine is enabled
  config = lib.mkIf cfg.enable {
    # Override the install script with our patched version
    system.build.installBootLoader = lib.mkForce limineInstallPatched;
  };
}
