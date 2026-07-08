return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        -- Buffer-local keymaps, set only when a language server attaches.
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
            callback = function(ev)
                local function map(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = "LSP: " .. desc })
                end

                -- Navigation / inspection: bare-key Vim idioms.
                map("gd", vim.lsp.buf.definition, "Go to definition")
                map("gD", vim.lsp.buf.declaration, "Go to declaration")
                map("gr", vim.lsp.buf.references, "List references")
                map("gi", vim.lsp.buf.implementation, "Go to implementation")
                map("gy", vim.lsp.buf.type_definition, "Go to type definition")
                map("K", vim.lsp.buf.hover, "Hover documentation")
                map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
                map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

                -- Act on this code: grouped under <localleader> (Space).
                map("<localleader>rn", vim.lsp.buf.rename, "Rename symbol")
                map("<localleader>ca", vim.lsp.buf.code_action, "Code action")
                map("<localleader>k", vim.lsp.buf.signature_help, "Signature help")
            end,
        })

        require("fidget").setup({})
        require("mason").setup()
        -- mason-lspconfig v2 dropped the `handlers` option; per-server config
        -- is now expressed via vim.lsp.config and must be set BEFORE the servers
        -- are enabled (automatic_enable calls vim.lsp.enable during setup below).

        -- Applied to every server: advertise nvim-cmp completion capabilities.
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        vim.lsp.config("bashls", {
            filetypes = { "sh", "bash", "zsh" },
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                    },
                },
            },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "ts_ls",
                "pyright",
                "clangd",
                "gopls",
                "bashls",
            },
            automatic_enable = true,
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- Navigate completion items
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),

                -- Confirm selection
                ['<CR>'] = cmp.mapping.confirm({ select = true }),

                -- Manual completion trigger
                ['<C-Space>'] = cmp.mapping.complete(),

                -- VSCode-style dismiss
                ["<Esc>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort() -- close the completion popup
                    end
                    vim.api.nvim_feedkeys(
                        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                        "n",
                        true
                    ) -- ensure we go back to normal mode
                end, { "i", "s" }),

                -- Tab / Shift-Tab for snippet navigation
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif require('luasnip').expand_or_jumpable() then
                        require('luasnip').expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),

                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif require('luasnip').jumpable(-1) then
                        require('luasnip').jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

        -- Command line `/` and `?`
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = 'buffer' } }
        })

        -- Command line `:` (commands)

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline({
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        cmp.complete() -- open the cmp popup manually
                    end
                end, { "c" }),         -- "c" means command-line mode
                ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            }),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })
    end
}
