local M = {}

M.init = function()
    local map = vim.keymap.set

    map('n', 'tn', ':bnext<CR>')
    map('n', 'tp', ':bprevious<CR>')
    map('n', 'tc', ':enew<CR>')
    map('n', ';;', ':set list!<CR>', { silent = true })  -- Toggle whitespace highlighting
    map('n', '<C-l>', ':noh<CR>:let @/ = ""<CR>', { nowait = true, silent = true }) -- Clear search
    map('n', ',,', ':set nu!<CR>:set rnu!<CR>', { nowait = true, silent = true }) -- Toggle line numbers
end

M.hop = {
    {
        '<Leader>f',
        function()
            require('hop').hint_words({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = false })
        end,
        desc = 'Walk forwards',
    },
    {
        '<Leader>F',
        function()
            require('hop').hint_words({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = false })
        end,
        desc = 'Walk backwards'
    },
    {
        '<Leader>w',
        function()
            require('hop').hint_words({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true })
        end,
        desc = 'Walk on current line'
    },
}

M.telescope = function()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')

    return {
        {
            'tl',
            builtin.buffers
        },
        {
            'tf',
             builtin.find_files
        },
        {
            'tq',
            builtin.help_tags
        },
        {
            'tg',
            builtin.live_grep
        },
        {
            'th',
            builtin.oldfiles
        },
        {
            't;',
            builtin.command_history
        },
        {
            'tt',
            builtin.tags
        },
        {
            'tm',
            builtin.marks
        },
        {
            'tq',
            builtin.registers
        },
        {
            't/',
            builtin.man_pages
        },
        {
            'tr',
            telescope.extensions.harpoon.marks
        },
    }
end

M.cscope_leader = "cc"

M.harpoon = function()

    return {

    }
end

return M
