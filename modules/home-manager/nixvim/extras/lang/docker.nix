{pkgs, ...}: {
  extraPackages = with pkgs; [
    hadolint
  ];

  plugins = {
    lsp.servers = {
      dockerls.enable = true;
      docker_compose_language_service.enable = true;
    };
    lint.lintersByFt = {
      dockerfile = ["hadolint"];
    };
  };
}
