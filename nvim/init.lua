vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

require("vim._core.ui2").enable()

require("core.options")
require("core.keymaps")
require("core.autocmd")
require("core.lazy")
require("core.diagnostics")
require("core.lsp")
require("core.hardmode")
