{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/server/common.nix
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
