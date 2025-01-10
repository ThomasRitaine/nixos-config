{ config, pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      stylua
      ripgrep
    ];

    extraPlugins = with pkgs.vimPlugins; [
      lazy-nvim
      blink-cmp
      bufferline-nvim
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      conform-nvim
      dashboard-nvim
      dressing-nvim
      flash-nvim
      friendly-snippets
      gitsigns-nvim
      grug-far-nvim
      indent-blankline-nvim
      lazydev-nvim
      lualine-nvim
      luvit-meta
      neo-tree-nvim
      noice-nvim
      nui-nvim
      nvim-cmp
      nvim-lint
      nvim-lspconfig
      nvim-snippets
      nvim-treesitter
      nvim-treesitter-textobjects
      nvim-ts-autotag
      persistence-nvim
      plenary-nvim
      snacks-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      todo-comments-nvim
      tokyonight-nvim
      trouble-nvim
      ts-comments-nvim
      which-key-nvim
      catppuccin-nvim
      mini-nvim
      fzf-lua # Explicitly add fzf-lua
    ];

    extraConfigLua =
      let
        plugins = with pkgs.vimPlugins; [
          LazyVim
          lazy-nvim
          blink-cmp
          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          conform-nvim
          dashboard-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          grug-far-nvim
          indent-blankline-nvim
          lazydev-nvim
          lualine-nvim
          luvit-meta
          neo-tree-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-snippets
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          persistence-nvim
          plenary-nvim
          snacks-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          which-key-nvim
          fzf-lua
          { name = "catppuccin"; path = catppuccin-nvim; }
          { name = "mini.ai"; path = mini-nvim; }
          { name = "mini.icons"; path = mini-nvim; }
          { name = "mini.pairs"; path = mini-nvim; }
        ];
        mkEntryFromDrv = drv:
          if lib.isDerivation drv then
            { name = "${lib.getName drv}"; path = drv; }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = {
            lazy = true
          },
          dev = {
            path = "${lazyPath}",
            patterns = { "" },
            fallback = false
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "williamboman/mason.nvim", enabled = false },
            { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end }
          }
        })
      '';
  };
}

