{pkgs, ...}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/nixos/zsh.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/vps/applications-backup.nix
    ../../modules/nixos/vps/firewall.nix
    ../../modules/nixos/vps/openssh.nix
    ../../modules/nixos/vps/fail2ban.nix
    ./users.nix
  ];

  system.stateVersion = "24.11";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    initrd.systemd.enable = true;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "vps-orarm";

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  environment.systemPackages = with pkgs; [
    git
  ];
}
