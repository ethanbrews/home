return {
    "stevearc/oil.nvim",
    lazy = true,
    command = "Oil",
    opts = {

    },
    keys = {
        {
            'to',
            function()
                require('oil').open()
            end,
            desc = 'Open Oil in the current buffer'
        }
    }
}
