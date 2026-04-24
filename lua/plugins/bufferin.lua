return {
  {
    "wasabeef/bufferin.nvim",
    config = function()
      require("bufferin").setup({
        style = "slant",
        show_bufferline = true,
        show_bufferline_in_current_tab = false,
      })
    end,
  },
}
