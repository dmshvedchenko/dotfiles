return {
  {
    "MeanderingProgrammer/render-markdown.nvim",

    ft = {
      "markdown",
    },

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },

    opts = {
      preset = "obsidian",

      render_modes = {
        "n",
        "c",
        "t",
      },

      completions = {
        lsp = {
          enabled = true,
        },
      },

      heading = {
        sign = false,
      },

      code = {
        sign = false,
        width = "block",
      },
    },

    keys = {
      {
        "<leader>mr",
        "<cmd>RenderMarkdown toggle<cr>",
        desc = "Toggle Markdown rendering",
      },
    },
  },
}
