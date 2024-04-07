if (not vim.g.neorg_plugin) then
    return { }
end

config = function()
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
        	}
        }
    }
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
