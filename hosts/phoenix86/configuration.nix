{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/server/common.nix
    ./users.nix
  ];

  system.stateVersion = "24.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  networking.hostName = "phoenix86";
}
