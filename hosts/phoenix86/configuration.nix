{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ../../modules/nixos/server/common.nix
    ../../modules/nixos/cloudflared.nix
  ];

  system.stateVersion = "24.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  networking.hostName = "phoenix86";
  networking.networkmanager.enable = true;
}
