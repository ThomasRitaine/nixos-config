{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/server/common.nix
    ../../modules/nixos/beszel-agent.nix
    ../../modules/nixos/tailscale.nix
    (import ../../modules/nixos/garage.nix { })
    (import ../../modules/nixos/restic { inherit config lib pkgs; })
    ./users.nix
  ];

  system.stateVersion = "26.05";
  garageAutoCapacity = "350G";
  boot = {
    loader.timeout = 5;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "consoleblank=30" ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  networking.hostName = "antoinette";
  networking.networkmanager.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
