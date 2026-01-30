{ pkgs, inputs, ... }: {
  imports = [
    inputs.agenix.nixosModules.default
    ../fish.nix
    ../docker.nix
    ../garbage-collector.nix
    ./applications-backup/config.nix
    ./traefik/config.nix
    ./firewall.nix
    ./openssh.nix
    ./fail2ban.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  environment.systemPackages = with pkgs; [ git ];
}
