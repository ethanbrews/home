local opts = {
    options = {
        cursorline = true,
        transparency = false,
    },
    colors = {
        dark_red =    "require('onedarkpro.helpers').darken('red', 45, 'onedark')",
        dark_yellow = "require('onedarkpro.helpers').darken('yellow', 45, 'onedark')",
        dark_blue =   "require('onedarkpro.helpers').darken('blue', 40, 'onedark')",
        dark_orange = "require('onedarkpro.helpers').darken('orange', 25, 'onedark')",
        dark_green =  "require('onedarkpro.helpers').darken('green', 35, 'onedark')",
        dark_purple = "require('onedarkpro.helpers').darken('purple', 35, 'onedark')",
        dark_cyan =   "require('onedarkpro.helpers').darken('cyan', 25, 'onedark')"
    },
    highlights = {
        CursorLine = { bg = "#1b1713" },
        CursorLineNR = { fg = "#dcc7a0", bg = "#1b1713" },
        HopNextKey = { fg = "#67b0ff", bg = "#414858" },
        HopNextKey1 = { fg = "#ffdd88", bg = "#414858" },
        HopNextKey2 = { fg = "#ccb06c", bg = "#414858" },
        Search = { underline = true, fg = "#e5c07b", bg = "#414858" },

        IndentRed =    { fg = "${dark_red}" },
        IndentYellow = { fg = "${dark_yellow}" },
        IndentBlue =   { fg = "${dark_blue}" },
        IndentOrange = { fg = "${dark_orange}" },
        IndentGreen =  { fg = "${dark_green}" },
        IndentPurple = { fg = "${dark_purple}" },
        IndentCyan =   { fg = "${dark_cyan}" },
    },
}

return {
    "olimorris/onedarkpro.nvim",
    opts = opts,
    init = function()
        vim.cmd("colorscheme onedark")
    end   
}
