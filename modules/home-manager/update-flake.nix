{ config, pkgs, hostFlakeName ? "default-flake", ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "update" ''
      #!/usr/bin/env bash

      if [ "$1" = "-t" ] || [ "$1" = "--test" ]; then
        sudo nixos-rebuild test --flake /etc/nixos/#${hostFlakeName}
      else
        sudo nixos-rebuild switch --flake /etc/nixos/#${hostFlakeName}
      fi
    '')
  ];
}

