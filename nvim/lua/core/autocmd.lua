local api = vim.api

local augroup = api.nvim_create_augroup("core_autocmds", { clear = true })

-- Don't auto comment new line
api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize splits when terminal is resized
api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("wincmd =")
  end,
})
