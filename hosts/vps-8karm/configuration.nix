{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/zsh.nix
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowPing = false;
  };

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

  systemd.services.backup = {
    description = "Run the backup script for app-manager";
    serviceConfig = {
      Type = "oneshot";
      User = "app-manager";
      ExecStart = "${pkgs.zsh}/bin/zsh /home/app-manager/server-config/backup/cron_backup.sh";
      StandardOutput = "append:/home/app-manager/server-config/backup/logs/cron_run.log";
      StandardError = "append:/home/app-manager/server-config/backup/logs/cron_run.log";
    };
    path = with pkgs; [
      docker
      jq
      gnutar
      gzip
      awscli2
    ];
  };

  systemd.timers.backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "02:00";
    };
  };
}
