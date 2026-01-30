{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];
}
