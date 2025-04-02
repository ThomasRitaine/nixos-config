{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ zsh ];

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;
}
