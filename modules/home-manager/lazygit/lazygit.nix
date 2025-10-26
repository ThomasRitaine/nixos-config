{ pkgs }:
let
  # Function to convert YAML to JSON using yj
  importYaml = file:
    builtins.fromJSON (builtins.readFile
      (pkgs.runCommandNoCC "converted-yaml.json" { } ''
        ${pkgs.yj}/bin/yj < "${file}" > "$out"
      ''));

  # Create the AI commit script
  aiCommitScript = pkgs.writeShellScriptBin "ai-commit.sh" ''
    ${builtins.readFile ./ai-commit.sh}
  '';
in {
  programs.lazygit = {
    enable = true;
    settings = importYaml ./config.yml;
  };

  # Make the script available in the environment
  home.packages = [ pkgs.aichat aiCommitScript ];
}
