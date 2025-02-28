return {
    "smoka7/hop.nvim",
    keys = require('config.keymaps').hop,
    config = function()
        require('hop').setup()
    end
}
