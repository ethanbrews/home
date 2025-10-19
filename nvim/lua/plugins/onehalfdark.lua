return {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        options = {
            cursorline = true,
            transparency = false,
        },
        highlights = {
            CursorLine = { bg = "#1b1713" },
            CursorLineNR = { fg = "#dcc7a0", bg = "#1b1713" },
            HopNextKey = { fg = "#99CAFF", bg = "#232628" },
            HopNextKey1 = { fg = "#ffdd88", bg = "#232628" },
            HopNextKey2 = { fg = "#ccb06c", bg = "#232628" },
            Search = { underline = true, fg = "#e5c07b", bg = "#414858" },
        },
        styles = {
            comments = "italic",
            keywords = "bold,italic",
            functions = "italic",
            conditionals = "italic"
        }
    },
    init = function()
        vim.cmd("colorscheme onedark")
    end
}
