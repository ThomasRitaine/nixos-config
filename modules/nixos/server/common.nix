{ pkgs, inputs, ... }: {
  imports = [
    inputs.agenix.nixosModules.default
    ../garbage-collector.nix
    ./firewall.nix
    ./openssh.nix
    ./fail2ban.nix
    ./sudo.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  environment.systemPackages = with pkgs; [ git ];
}
