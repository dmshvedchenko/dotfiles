return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",

    cmd = {
      "Obsidian",
    },

    dependencies = {
      "nvim-telescope/telescope.nvim",
    },

    opts = {
      legacy_commands = false,

      workspaces = {
        {
          name = "personal",
          path = vim.fn.expand(
            "~/Library/Mobile Documents/com~apple~CloudDocs/MyFiles/Dima/Docs/ObsidianNotes"
          ),
        },
      },

      picker = {
        name = "telescope.nvim",
      },

      ui = {
        enable = false,
      },

      completion = {
        blink = true,
        min_chars = 2,
      },
    },
  },
}
