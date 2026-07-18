return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
      local treesitter = require("nvim-treesitter")

      local parser_install_dir = vim.fn.stdpath("data") .. "/site"

      local parsers = {
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
        "terraform",
        "hcl",
        "dockerfile",
        "gitignore",
        "make",
        "perl",
        "markdown",
        "markdown_inline",
      }

      -- The main branch automatically prepends install_dir
      -- to runtimepath.
      treesitter.setup({
        install_dir = parser_install_dir,
      })

      -- Equivalent to the old ensure_installed list.
      -- Installation runs asynchronously and is a no-op for parsers
      -- that are already installed.
      treesitter.install(parsers)

      local group = vim.api.nvim_create_augroup(
        "UserTreesitterConfig",
        { clear = true }
      )

      -- Equivalent to:
      --
      -- highlight = { enable = true }
      --
      -- The new main branch uses Neovim's built-in Tree-sitter
      -- highlighting API.
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          local filetype = vim.bo[args.buf].filetype
          local language = vim.treesitter.language.get_lang(filetype)

          if not language then
            return
          end

          local parser_available = pcall(
            vim.treesitter.language.add,
            language
          )

          if not parser_available then
            return
          end

          pcall(vim.treesitter.start, args.buf, language)
        end,
      })

      -- Equivalent to:
      --
      -- indent = { enable = true }
      --
      -- Tree-sitter indentation remains experimental.
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = {
          "bash",
          "dockerfile",
          "gitignore",
          "hcl",
          "json",
          "lua",
          "make",
          "markdown",
          "perl",
          "python",
          "terraform",
          "vim",
          "yaml",
        },
        callback = function(args)
          vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
