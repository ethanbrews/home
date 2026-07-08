return {
    "stevearc/oil.nvim",
    lazy = false, -- Looking for a solution to lazy load and open oil with `nvim .`
    cmd = "Oil",
    event = { "BufEnter" },
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
