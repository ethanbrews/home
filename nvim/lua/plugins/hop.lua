return {
    'smoka7/hop.nvim',
    version = "*",
    opts = {
        keys = 'etovxqpdygfblzhckisuran'
    },
    keys = {
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
        {
            '<Leader>b',
            function()
                require('hop').hint_words({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true })
            end,
            desc = 'Walk backwards on current line'
        }
    }
}
