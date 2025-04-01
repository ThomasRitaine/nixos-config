{pkgs, ...}: {
  home.packages = [
    pkgs.zoxide
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };
}
