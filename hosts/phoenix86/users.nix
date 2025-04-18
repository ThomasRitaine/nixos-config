{ pkgs, inputs, ... }:
let
  usersModule = import ../../modules/nixos/users/common.nix {
    inherit pkgs inputs;
    hostFlakeName = "phoenix86";
  };
in usersModule
