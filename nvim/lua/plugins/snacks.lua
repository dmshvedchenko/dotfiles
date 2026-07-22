return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = {
        enabled = true,
        ui_select = true,
      },
      notifier = {
        enabled = false,
      },
      quickfile = {
        enabled = true,
      },
      scroll = {
        enabled = true,
      },
      input = {
        enabled = false,
      },
      scope = {
        enabled = true,
      },
      words = {
        enabled = true,
      },
      image = {
        enabled = true,
        doc = {
          enabled = true,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
      },
    },
    keys = {
      {
         "<leader>tt",
          function()
            Snacks.terminal.toggle(nil, {
              cwd = vim.fn.getcwd(),
              win = {
                position = "float",
                border = "rounded",
                width = 0.75,
                height = 0.75,
              },
            })
          end,
          desc = "Terminal: Toggle Floating",
          mode = { "n", "t" },
        },
       },
  }
}
