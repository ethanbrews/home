return {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
        "mason-org/mason.nvim",
        "neovim/nvim-lspconfig",
    },
    keys = {
        {
            "gl",
            vim.diagnostic.open_float
        }
    }
}
