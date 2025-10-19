return {
    "nvimdev/indentmini.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("indentmini").setup()
    end,
}
