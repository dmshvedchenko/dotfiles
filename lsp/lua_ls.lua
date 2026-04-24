local blink = require("blink.cmp")

return {
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local dir = vim.fs.dirname(fname)

        local root = vim.fs.find({ ".git", ".luarc.json", ".luarc.jsonc", "init.lua" }, {
            upward = true,
            path = dir,
        })[1]

        if root then
            on_dir(vim.fs.dirname(root))
            return
        end

        on_dir(dir)
    end,
    capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        blink.get_lsp_capabilities(),
        {
            fileOperations = {
                didRename = true,
                willRename = true,
            },
        }
    ),
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
                maxPreload = 1000,
                preloadFileSize = 200,
            },
            telemetry = {
                enable = false,
            },
            diagnostics = {
                globals = { "vim" },
            },
            hint = {
                enable = true,
            },
        },
    },
}
