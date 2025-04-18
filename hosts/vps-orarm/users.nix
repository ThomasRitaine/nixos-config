{ pkgs, inputs, ... }:
let
  usersModule = import ../../modules/nixos/users/common.nix {
    inherit pkgs inputs;
    hostFlakeName = "vps-orarm";
  };
in usersModule
