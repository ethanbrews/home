local config = function()

    --[[ local highlight = {
        "IndentRed",
        "IndentYellow",
        "IndentBlue",
        "IndentOrange",
        "IndentGreen",
        "IndentPurple",
        "IndentCyan",
    } ]]--

    require('ibl').setup {
        indent = {
         --   highlight = highlight,
         --   char = '╎'
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = false,
            injected_languages = false,
            priority = 500,
        }
    }
end

return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config=config
}
