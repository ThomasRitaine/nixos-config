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
        };

        formatters = {
          alejandra = {
            command = lib.getExe pkgs.alejandra;
          };
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
