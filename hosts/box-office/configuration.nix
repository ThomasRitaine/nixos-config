{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-acceleration.nix
    ./hardware-configuration.nix
    ../../modules/nixos/server/common.nix
    ../../modules/nixos/beszel-agent.nix
    (import ../../modules/nixos/tailscale.nix { tags = [ ]; })
    (import ../../modules/nixos/restic { inherit config lib pkgs; })
    ./users.nix
    ./frigate-external-drive.nix
    ../../modules/nixos/home-automation/frigate.nix
    ../../modules/nixos/home-automation/home-assistant.nix
    ../../modules/nixos/home-automation/air-gapped-camera.nix
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
