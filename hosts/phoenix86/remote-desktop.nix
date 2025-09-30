{ pkgs, ... }: {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = false;
  services.desktopManager.gnome.enable = true;

  boot.kernelParams = [ "video=HDMI-1:1920x1080@60" "video=eDP-1:d" ];

  boot.initrd.availableKernelModules = [ "i915" ];

  environment.systemPackages = with pkgs; [ rustdesk-flutter xorg.xinput ];

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

    home.packages = with pkgs; [ firefox gnome-shell-extensions ];

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "fr" ]) ];
        xkb-options = [ ];
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [ "desktop-icons@csoriano" ];
      };

      "org/gnome/nautilus/preferences" = {
        executable-text-activation = "launch";
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

    home.file.".config/autostart/disable-laptop-keyboard.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Disable Laptop Keyboard
      Exec=${pkgs.bash}/bin/bash -c "sleep 5 && ${pkgs.xorg.xinput}/bin/xinput float 12"
      Hidden=false
      NoDisplay=true
      X-GNOME-Autostart-enabled=true
      StartupNotify=false
    '';

    home.file.".local/share/applications/enable-keyboard.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Enable Keyboard
        Comment=Enable the laptop keyboard
        Exec=${pkgs.bash}/bin/bash -c "${pkgs.xorg.xinput}/bin/xinput reattach 12 3 && ${pkgs.libnotify}/bin/notify-send 'Keyboard Enabled' 'Laptop keyboard is now active'"
        Icon=input-keyboard
        Terminal=false
        Categories=Utility;
      '';
    };

    home.file.".local/share/applications/disable-keyboard.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Disable Keyboard
        Comment=Disable the laptop keyboard
        Exec=${pkgs.bash}/bin/bash -c "${pkgs.xorg.xinput}/bin/xinput float 12 && ${pkgs.libnotify}/bin/notify-send 'Keyboard Disabled' 'Laptop keyboard is now disabled'"
        Icon=input-keyboard-symbolic
        Terminal=false
        Categories=Utility;
      '';
    };

    home.file.".local/share/applications/netflix.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=Netflix
        Comment=Open Netflix in fullscreen
        Exec=${pkgs.firefox}/bin/firefox --kiosk https://www.netflix.com
        Icon=firefox
        Terminal=false
        Categories=AudioVideo;Video;
      '';
    };
  };
}
