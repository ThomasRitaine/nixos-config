{
  pkgs,
  lib,
  ...
}: {
  plugins = {
    conform-nvim = {
      enable = true;

      settings = {
        formatters_by_ft = {
          nix = ["alejandra"];
          python = ["isort" "black"];
          eslint_d = ["eslint_d"];
        };

        formatters = {
          alejandra.command = lib.getExe pkgs.alejandra;
          isort.command = lib.getExe pkgs.isort;
          black.command = lib.getExe pkgs.black;
          eslint_d.command = lib.getExe pkgs.eslint_d;
        };

        luaConfig.post = ''
          -- Create an autocommand for formatting on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*",
            callback = function(args)
              require("conform").format({ bufnr = args.buf })
            end,
          })
        '';
      };
    };
  };
}
