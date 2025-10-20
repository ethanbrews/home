return {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signcolumn = true
    },
    keys = {
        -- Navigation
        {
            '<leader>gj',
            function() require('gitsigns').next_hunk() end,
            desc = 'Next git hunk',
        },
        {
            '<leader>gk',
            function() require('gitsigns').prev_hunk() end,
            desc = 'Previous git hunk',
        },

        -- Actions
        {
            '<leader>gs',
            function() require('gitsigns').stage_hunk() end,
            desc = 'Stage hunk',
        },
        {
            '<leader>gr',
            function() require('gitsigns').reset_hunk() end,
            desc = 'Reset hunk',
        },
        {
            '<leader>gu',
            function() require('gitsigns').undo_stage_hunk() end,
            desc = 'Undo stage hunk',
        },
        {
            '<leader>gp',
            function() require('gitsigns').preview_hunk() end,
            desc = 'Preview hunk',
        },
        {
            '<leader>gb',
            function() require('gitsigns').blame_line({ full = true }) end,
            desc = 'Blame line',
        },

        -- Diff
        {
            '<leader>gd',
            function() require('gitsigns').diffthis() end,
            desc = 'Diff this buffer',
        },
        {
            '<leader>gD',
            function() require('gitsigns').diffthis('~') end,
            desc = 'Diff against HEAD~1',
        },

        -- Visual mode actions
        {
            '<leader>gs',
            function() require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
            mode = 'v',
            desc = 'Stage selection',
        },
        {
            '<leader>gr',
            function() require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
            mode = 'v',
            desc = 'Reset selection',
        },
    },
}
