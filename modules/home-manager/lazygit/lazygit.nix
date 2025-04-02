{ pkgs }:
let
  # Function to convert YAML to JSON using yj
  importYaml = file:
    builtins.fromJSON (builtins.readFile
      (pkgs.runCommandNoCC "converted-yaml.json" { } ''
        ${pkgs.yj}/bin/yj < "${file}" > "$out"
      ''));
in {
  programs.lazygit = {
    enable = true;
    settings = importYaml ./config.yml;
  };
}
