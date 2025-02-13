{pkgs}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };

  home.file.".config/nvim".source = ./config;

  home.packages = with pkgs; [
    fd
  ];
}
