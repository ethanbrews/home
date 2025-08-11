if (not vim.g.neorg_plugin) then
    return { }
end

NeorgToggleConcealer = function()
    if vim.opt.conceallevel:get() == 0 then
        vim.opt.conceallevel = 2
    else
        vim.opt.conceallevel = 0
    end
    if vim.bo.filetype == 'norg' then
        vim.cmd 'Neorg toggle-concealer'
    end
end

SetConcealLevel = function(value)
    vim.opt.conceallevel = value
end

local config = function()
    require('neorg').setup {
        load = {
            ['core.defaults'] = {},
            ['core.concealer'] = {},
            ['core.dirman'] = { 
                config = {
                    workspaces = {
                        notes = '~/notes',
                    },
                    default_workspace = 'notes'
                }
        	},
            ['core.export'] = {}
        }
    }

    vim.cmd [[
        command! -nargs=* Notes Neorg workspace notes
        command! -nargs=* Re Neorg return
        command! -nargs=0 Conceal lua NeorgToggleConcealer()
        autocmd FileType norg lua SetConcealLevel(2)
        autocmd BufLeave *.norg lua SetConcealLevel(0)
    ]]
end

return {
    {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = true
    },
    { 
        "nvim-neorg/neorg",
        dependencies = { "luarocks.nvim" },
        lazy = false,
        version = "*",
        config = config
    }
}
