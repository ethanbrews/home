return {
    'numToStr/Comment.nvim',
    opts = {
        mappings = {
            basic = false,
            extra = false,
        },
    },
    keys = {
        {
            '<localleader>cc',
            function() require('Comment.api').toggle.linewise.current() end,
            mode = 'n',
            desc = 'Comment: toggle line (current)'
        },
        {
            '<localleader>cb',
            function() require('Comment.api').toggle.blockwise.current() end,
            mode = 'n',
            desc = 'Comment: toggle block (current)'
        },
        {
            '<localleader>cc',
            function()
                local api = require('Comment.api')
                -- leave visual mode and call toggle on the visual selection
                local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
                vim.api.nvim_feedkeys(esc, 'nx', false)
                api.toggle.linewise(vim.fn.visualmode())
            end,
            mode = 'x',
            desc = 'Comment: toggle line (selection)'
        },
        {
            '<localleader>cb',
            function()
                local api = require('Comment.api')
                local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
                vim.api.nvim_feedkeys(esc, 'nx', false)
                api.toggle.blockwise(vim.fn.visualmode())
            end,
            mode = 'x',
            desc = 'Comment: toggle block (selection)'
        },
    }
}
