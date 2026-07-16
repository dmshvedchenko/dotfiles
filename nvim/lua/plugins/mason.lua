return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "bashls",
          "ansiblels",
          "yamlls",
          "helm_ls",
          "pylsp",
          "dockerls",
          "ltex_plus",
          "systemd_lsp",
          "jsonls",
          "terraformls"
        },
      })
    end,
  },
}
