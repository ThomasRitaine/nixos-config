{ ... }: {
  imports = [ ../../modules/nixos/server/users.nix ];

  hostFlakeName = "vps-orarm";
}
