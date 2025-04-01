{ pkgs, ... }: {
  imports = [
    ./zsh.nix
    ./docker.nix
    ./vps/applications-backup.nix
    ./vps/firewall.nix
    ./vps/openssh.nix
    ./vps/fail2ban.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fr";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  environment.systemPackages = with pkgs; [
    git
  ];
}
