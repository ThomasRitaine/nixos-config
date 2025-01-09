{ config, pkgs, inputs, updateType ? "default", hostFlakeName ? "default-flake", flakePath ? "/etc/nixos", ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "update" ''
      #!/usr/bin/env bash

      # Parse update type from Nix parameter
      case "${updateType}" in
        "nixos")
          if [ "$1" = "-t" ] || [ "$1" = "--test" ]; then
            echo "Performing NixOS test update..."
            sudo nixos-rebuild test --flake "${flakePath}#${hostFlakeName}"
          else
            echo "Performing NixOS switch update..."
            sudo nixos-rebuild switch --flake "${flakePath}#${hostFlakeName}"
          fi
          ;;
        "home-manager")
          echo "Performing Home Manager update..."
          home-manager switch --flake "${flakePath}#${hostFlakeName}"
          ;;
        *)
          echo "Unknown update type: ${updateType}"
          echo "Please specify 'nixos' or 'home-manager' as the update type."
          exit 1
          ;;
      esac
    '')
  ];
}

