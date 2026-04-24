vim.g.mapleader = " "

local keymap = vim.keymap.set

-- LSP
keymap("n", "<leader>la", function()
  vim.lsp.buf.code_action({ apply = true })
end, { desc = "Code Action" })

keymap("v", "<leader>lA", function()
  vim.lsp.buf.code_action({ apply = true })
end, { desc = "Range Code Action" })

keymap("n", "<leader>ls", vim.lsp.buf.signature_help, { desc = "Signature Help" })
keymap("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
keymap("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format" })
keymap("n", "<leader>lh", vim.lsp.buf.hover, { desc = "Hover" })
keymap("n", "<leader>lR", vim.lsp.buf.references, { desc = "References" })
keymap("n", "<leader>li", vim.lsp.buf.implementation, { desc = "Implementation" })
keymap("n", "<leader>lo", vim.diagnostic.open_float, { desc = "Open Diagnostics Float" })
keymap("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Definition" })
keymap("n", "<leader>lD", vim.lsp.buf.type_definition, { desc = "Type Definition" })
keymap("n", "<leader>lg", vim.lsp.buf.declaration, { desc = "Declaration" })

-- Window management
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split Vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split Horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equalize Splits" })
keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close Split" })

-- Tabs
keymap("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open New Tab" })
keymap("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close Current Tab" })
keymap("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next Tab" })
keymap("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Previous Tab" })

-- Copilot Chat
keymap("n", "<leader>co", "<cmd>CopilotChatOpen<CR>", { desc = "Open Copilot Chat" })
keymap("n", "<leader>cx", "<cmd>CopilotChatClose<CR>", { desc = "Close Copilot Chat" })
keymap("n", "<leader>cc", "<cmd>CopilotChatToggle<CR>", { desc = "Toggle Copilot Chat" })
keymap("n", "<leader>cs", "<cmd>CopilotChatStop<CR>", { desc = "Stop Copilot Chat" })
keymap("n", "<leader>cr", "<cmd>CopilotChatReset<CR>", { desc = "Reset Copilot Chat" })
