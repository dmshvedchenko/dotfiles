return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parser_install_dir = vim.fn.stdpath("data") .. "/site"
      vim.opt.runtimepath:prepend(parser_install_dir)

      local install = require("nvim-treesitter.install")
      install.prefer_git = true
      install.compilers = { "clang", "gcc" }
      install.parser_install_dir = parser_install_dir

      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "json",
          "lua",
          "luadoc",
          "luap",
          "python",
          "regex",
          "vim",
          "vimdoc",
          "yaml",
          "dockerfile",
          "gitignore",
          "make",
          "perl",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
