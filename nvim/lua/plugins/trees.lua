return {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    lazy = true,
    keys = {
        {
            '<localleader>m',
            function() require('treesj').toggle() end,
            desc = 'Toggle trees'
        },
        {
            '<localleader>j',
            function() require('treesj').join() end,
            desc = 'Join trees'
        },
        {
            '<localleader>s',
            function() require('treesj').split() end,
            desc = 'Split trees'
        },
        {
            '<localleader>M',
            function() require('treesj').toggle({ split = { recursive = true } }) end,
            desc = 'Toggle trees recursively',
        },
        {
            '<localleader>J',
            function() require('treesj').join() end,
            desc = 'Join trees recursively',
        },
        {
            '<localleader>S',
            function() require('treesj').split({ split = { recursive = true } }) end,
            desc = 'Split trees recursively',
        },
    },
    config = function()
        require('treesj').setup {

        }
    end,
}
