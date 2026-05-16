{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./remote-desktop.nix
    ./users.nix
    ./nginx.nix
    ../../modules/nixos/server/common.nix
    ../../modules/nixos/cloudflared.nix
    ../../modules/nixos/beszel-agent.nix
    ../../modules/nixos/tailscale.nix
    (import ../../modules/nixos/garage.nix { })
    (import ../../modules/nixos/restic { inherit config lib pkgs; })
  ];

  system.stateVersion = "24.11";
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

  networking.hostName = "phoenix86";
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
