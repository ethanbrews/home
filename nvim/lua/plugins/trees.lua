return {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    lazy = true,
    keys = {
        {
            '<localleader>m',
            desc = 'Toggle trees'
        },
        {
            '<localleader>j',
            desc = 'Join trees'
        },
        {
            '<localleader>s',
            desc = 'Split trees'
        },
        {
            '<localleader>M',
            function() require('treesj').toggle({ split = { recursive = true } }) end,
            desc = 'Toggle trees recursively',
        },
        {
            '<localleader>J',
            function() require('treesj').toggle({ split = { recursive = true } }) end,
            desc = 'Join trees recursively',
        },
        {
            '<localleader>S',
            function() require('treesj').toggle({ split = { recursive = true } }) end,
            desc = 'Split trees recursively',
        },
    },
    config = function()
        require('treesj').setup {

        }
    end,
}
