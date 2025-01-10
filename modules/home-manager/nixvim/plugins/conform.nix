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

        format_on_save = ''
          function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end

            if slow_format_filetypes[vim.bo[bufnr].filetype] then
              return
            end

            local function on_format(err)
              if err and err:match("timeout$") then
                slow_format_filetypes[vim.bo[bufnr].filetype] = true
              end
            end

            return { timeout_ms = 200, lsp_fallback = true }, on_format
           end
        '';
      };
    };
  };
}
