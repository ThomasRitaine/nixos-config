{ pkgs, ... }:
{
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;

  services.desktopManager.gnome.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "tissou";
  };

  services.displayManager.defaultSession = "gnome";

  boot.kernelParams = [ "video=HDMI-1:1920x1080@60" ];
  boot.initrd.availableKernelModules = [ "i915" ];

  environment.systemPackages = with pkgs; [ xinput ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="AT Translated Set 2 keyboard", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  services.gnome.gnome-keyring.enable = true;

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  users.users.tissou = {
    isNormalUser = true;
    description = "TISSOU";
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhhJyyQRqM+Bq7vBrzwrZIr1hnEbmfrzYXU5kXHIMCm app-manager"
    ];
  };

  home-manager.users.tissou =
    { pkgs, lib, ... }:
    {
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
      home.packages = with pkgs; [
        rustdesk-flutter
        firefox
        gnome-shell-extensions
      ];
      dconf.settings = {
        "org/gnome/desktop/input-sources" = {
          sources = [
            (lib.hm.gvariant.mkTuple [
              "xkb"
              "fr"
            ])
          ];
          xkb-options = [ ];
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [ "desktop-icons@csoriano" ];
        };
        "org/gnome/nautilus/preferences" = {
          executable-text-activation = "launch";
        };
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
        "org/gnome/desktop/interface" = {
          text-scaling-factor = 2.0;
        };
      };
      home.file.".config/autostart/rustdesk.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=RustDesk
        Exec=${pkgs.rustdesk-flutter}/bin/rustdesk
        X-GNOME-Autostart-enabled=true
      '';
    };
}
