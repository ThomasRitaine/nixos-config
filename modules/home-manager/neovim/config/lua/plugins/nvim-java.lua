-- require("java").setup()
-- require("lspconfig").jdtls.setup({
--   settings = {
--     java = {
--       configuration = {
--         runtimes = {
--           {
--             name = "JavaSE-21",
--             path = "/usr/lib/jvm/java-21-openjdk-amd64", -- Correct path to the JDK directory
--             default = true,
--           },
--         },
--       },
--     },
--   },
-- })

-- return { "nvim-java/nvim-java" }

return {
  "nvim-java/nvim-java",
  config = false,
  dependencies = {
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          jdtls = {
            -- Your custom jdtls settings goes here
          },
        },
        setup = {
          jdtls = function()
            require("java").setup({
              -- Your custom nvim-java configuration goes here
            })
          end,
        },
      },
    },
  },
}
