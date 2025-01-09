{ config, pkgs, inputs, updateType ? "default", hostFlakeName ? "default-flake", ... }:

let
  flakePath = inputs.self.outPath;
in {
  home.packages = [
    (pkgs.writeShellScriptBin "update" ''
      #!/usr/bin/env bash

      # Get the directory of this script
      FLAKE_PATH="${flakePath}"
      echo $FLAKE_PATH

      # Parse update type from Nix parameter
      case "${updateType}" in
        "nixos")
          if [ "$1" = "-t" ] || [ "$1" = "--test" ]; then
            echo "Performing NixOS test update..."
            sudo nixos-rebuild test --flake "$FLAKE_PATH#${hostFlakeName}"
          else
            echo "Performing NixOS switch update..."
            sudo nixos-rebuild switch --flake "$FLAKE_PATH#${hostFlakeName}"
          fi
          ;;
        "home-manager")
          echo "Performing Home Manager update..."
          home-manager switch --flake "$FLAKE_PATH#${hostFlakeName}"
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

