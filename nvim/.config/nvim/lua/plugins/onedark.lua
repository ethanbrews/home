local opts = {
    options = {
        transparency = true,
        cursorline = true,
    },
    highlights = {
        CursorLine = { bg = "#2a2e36" },
        CursorLineNR = { fg = "#dcc7a0", bg = "#2a2e36" },
        HopNextKey = { fg = "#67b0ff", bg = "#414858" },
        HopNextKey1 = { fg = "#ffdd88", bg = "#414858" },
        HopNextKey2 = { fg = "#ccb06c", bg = "#414858" },
        Search = { underline = true, fg = "#e5c07b", bg = "#414858" }
    }
}

return {
    "olimorris/onedarkpro.nvim",
    opts = opts,
    init = function()
        vim.cmd("colorscheme onedark")
    end
}
