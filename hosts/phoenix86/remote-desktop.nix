{ pkgs, ... }: {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = false;
  services.desktopManager.gnome.enable = true;

  boot.kernelParams = [ "video=HDMI-1:1920x1080@60" "video=eDP-1:d" ];

  boot.initrd.availableKernelModules = [ "i915" ];

  environment.systemPackages = with pkgs; [ rustdesk-flutter ];

  users.users.tissou = {
    isNormalUser = true;
    description = "TISSOU";
    extraGroups = [ "networkmanager" "video" "audio" ];
    initialPassword = "";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhhJyyQRqM+Bq7vBrzwrZIr1hnEbmfrzYXU5kXHIMCm app-manager"
    ];
  };

  security.pam.services.gdm-password.allowNullPassword = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "tissou";

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  home-manager.users.tissou = { pkgs, lib, ... }: {
    home.stateVersion = "24.11";
    programs.home-manager.enable = true;

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "fr" ]) ];
        xkb-options = [ ];
      };
    };

    home.file.".config/autostart/rustdesk.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=RustDesk
      Exec=${pkgs.rustdesk-flutter}/bin/rustdesk
      Hidden=false
      NoDisplay=false
      X-GNOME-Autostart-enabled=true
      StartupNotify=false
    '';
  };
}
