{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/server/common.nix
    ../../modules/nixos/beszel-agent.nix
    ../../modules/nixos/beszel-hub.nix
    ../../modules/nixos/fish.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/headscale.nix
    ../../modules/nixos/restic.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/applications-backup/config.nix
    ../../modules/nixos/traefik
    ./users.nix
  ];

  system.stateVersion = "24.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  networking.hostName = "vps-8karm";
}
