return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        {
            'tl',
            function() require('telescope.builtin').buffers() end,
            desc = "List open buffers"
        },
        {
            'tf',
            function() require('telescope.builtin').find_files() end,
            desc = "Live file finder"
        },
        {
            'tq',
            function() require('telescope.builtin').help_tags() end,
            desc = "Live tag search"
        },
        {
            'tg',
            function() require('telescope.builtin').live_grep() end,
            desc = "Live grep"
        },
        {
            'th',
            function() require('telescope.builtin').oldfiles() end,
            desc = "Search recent files"
        },
        {
            't;',
            function() require('telescope.builtin').command_history() end,
            desc = "Search recent commands"
        },
        {
            'tm',
            function() require('telescope.builtin').marks() end,
            desc = "Live marks search"
        },
        {
            'tq',
            function() require('telescope.builtin').registers() end,
            desc = "Live registers search"
        },
        {
            't/',
            function() require('telescope.builtin').man_pages() end,
            desc = "Search man pages"
        }
    }
}
