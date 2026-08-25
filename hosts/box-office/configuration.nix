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
    (import ../../modules/nixos/tailscale.nix { tags = [ ]; })
    (import ../../modules/nixos/restic { inherit config lib pkgs; })
    ./users.nix
  ];

  system.stateVersion = "26.11";

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

  networking.hostName = "box-office";
  networking.networkmanager.enable = true;
}
