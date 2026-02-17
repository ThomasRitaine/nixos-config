{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/nixos/server/common.nix
    ../../modules/nixos/beszel-agent.nix
    ../../modules/nixos/foldingathome.nix
    (import ../../modules/nixos/restic { inherit config lib pkgs; })
    ../../modules/nixos/tailscale.nix
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

  swapDevices = [{
    device = "/swapfile";
    size = 4096;
  }];
}
