local enabled = vim.g.format_on_save or false

vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(args)
        if enabled then
            require("conform").format({ bufnr = args.buf })
        end
    end,
});

vim.api.nvim_create_user_command("Format", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format current buffer" })

-- Map <leader>DF to the same action
vim.keymap.set("n", "<leader>DF", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file (Conform)" })


return {
    'stevearc/conform.nvim',
    event = { "VeryLazy", "BufWritePost" },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "isort", "black" },
            rust = { "rustfmt", lsp_format = "fallback" },
            javascript = { "prettierd", "prettier", stop_after_first = true },
        },
    },
}
