{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/zsh.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/vps/applications-backup.nix
    ../../modules/nixos/vps/firewall.nix
    ../../modules/nixos/vps/openssh.nix
    ../../modules/nixos/vps/fail2ban.nix
    ./users.nix
  ];

  system.stateVersion = "24.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "vps-8karm";

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  environment.systemPackages = with pkgs; [
    git
  ];
}
