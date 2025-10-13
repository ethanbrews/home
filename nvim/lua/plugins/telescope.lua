return {
	'nvim-telescope/telescope.nvim', tag = '0.1.8',
	dependencies = { 'nvim-lua/plenary.nvim' },
	keys = {
        {
            'tl',
            require('telescope.builtin').buffers
        },
        {
            'tf',
             require('telescope.builtin').find_files
        },
        {
            'tq',
            require('telescope.builtin').help_tags
        },
        {
            'tg',
            require('telescope.builtin').live_grep
        },
        {
            'th',
            require('telescope.builtin').oldfiles
        },
        {
            't;',
            require('telescope.builtin').command_history
        },
        {
            'tt',
            require('telescope.builtin').tags
        },
        {
            'tm',
            require('telescope.builtin').marks
        },
        {
            'tq',
            require('telescope.builtin').registers
        },
        {
            't/',
            require('telescope.builtin').man_pages
        }
    }
}
