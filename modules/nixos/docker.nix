{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ docker ];

  virtualisation.docker.enable = true;

  # Stop containers cleanly at shutdown instead of leaving them for
  # systemd-shutdown to kill
  virtualisation.docker.liveRestore = false;
}
