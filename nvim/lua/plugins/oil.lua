return {
    "stevearc/oil.nvim",
    lazy = false, -- Looking for a solution to lazy load and open oil with `nvim .`
    command = "Oil",
    events = { "BufEnter" },
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
