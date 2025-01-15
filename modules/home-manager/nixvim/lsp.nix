{
  plugins.lsp = {
    enable = true;

    servers = {
      nil_ls.enable = true; # Nix
      ts_ls.enable = true; # TypeScript
      pyright.enable = true; # Python
      bashls.enable = true;
      html.enable = true;
      cssls.enable = true;
    };
  };
}
