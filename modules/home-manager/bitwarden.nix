{ pkgs, config, ... }: {
  home.packages = with pkgs; [ bitwarden-desktop ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  };
}
