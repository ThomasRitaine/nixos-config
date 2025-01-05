{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/zsh.nix
    ../../modules/nixos/vps/applications-backup.nix
    ../../modules/nixos/vps/firewall.nix
    ./users.nix
  ];

  system.stateVersion = "24.05";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  swapDevices = [
    { device = "/swapfile"; size = 8192; }
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "vps-8karm";

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      ChallengeResponseAuthentication = false;
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  environment.systemPackages = with pkgs; [
    git
    docker
    awscli2
    jq
    starship
    neovim
  ];

  virtualisation.docker.enable = true;


  services.fail2ban = {
    enable = true;
    jails = {
      sshd = {
        enabled = true;
        settings = {
          port = "ssh";
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = "5";
        };
      };
    };
  };
}
