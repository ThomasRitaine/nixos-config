{
  plugins.lsp = {
    enable = true;

    servers = {
      nil_ls.enable = true; # Nix
      ts_ls.enable = true; # TypeScript
      pyright.enable = true; # Python
      bashls.enable = true;
      dockerls.enable = true;
      docker_compose_language_service.enable = true;
      html.enable = true;
      cssls.enable = true;
      jsonls.enable = true;
      yamlls = {
        enable = true;
        settings.yaml.schemas = {
          "https://json.schemastore.org/github-workflow.json" = "/.github/workflows/*";
        };
      };
    };
  };
}
