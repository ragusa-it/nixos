# modules/audio.nix
# Audio and Bluetooth configuration: Blueman GUI, volume control, media keys
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════
  # Bluetooth GUI management
  services.blueman.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # AUDIO PACKAGES
  # ═══════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    # PipeWire volume control
    pwvucontrol # Modern PipeWire volume control (Qt)
    pavucontrol # Classic PulseAudio volume control (GTK) - as backup
    helvum # PipeWire patchbay for routing audio
    qpwgraph # PipeWire graph editor (visual audio routing)

    # Media player control
    playerctl # Control media players via D-Bus (for media keys)

    # Audio tools
    easyeffects # Audio effects and equalizer for PipeWire

    # Bluetooth audio codecs are handled by PipeWire automatically
  ];

  # ═══════════════════════════════════════════════════════════════
  # BLUETOOTH CODECS
  # ═══════════════════════════════════════════════════════════════
  # Ensure PipeWire has good Bluetooth codec support
  # This is already configured in your main config, but we ensure AAC/LDAC support
  services.pipewire.wireplumber.extraConfig = {
    "10-bluez" = {
      "monitor.bluez.properties" = {
        # Enable all Bluetooth codecs
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;

        # Bluetooth headset roles
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "bap_sink"
          "bap_source"
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];

        # Codec preference order (highest quality first)
        "bluez5.codecs" = [
          "ldac"
          "aac"
          "aptx_hd"
          "aptx"
          "sbc_xq"
          "sbc"
        ];
      };
    };
  };
}
