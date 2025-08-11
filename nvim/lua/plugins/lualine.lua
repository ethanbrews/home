local format_mode = function(str)
    local mapping = {
        ['NORMAL']  = 'N',
        ['VISUAL']  = 'V',
        ['INSERT']  = 'I',
        ['V-BLOCK'] = 'B',
        ['COMMAND'] = 'C',
    }

    if mapping[str] then
        return mapping[str]
    else
        return str
    end
end

local config = function()
    require('lualine').setup {
        options = { 
            theme = 'onedark',
            icons_enabled = false,
            always_divide_middle = true,
            refresh = {
                statusline = 1000,
                tabline = 1000,
                winbar = 1000,
            },
            component_separators = { left = '|', right = '|' },
            section_separators = { left = '', right = '' }
        },
        sections = {
            lualine_a = { { 'mode', fmt = format_mode } },
            lualine_b = {  },
            lualine_c = {'filename'},
    
            lualine_x = { 'progress', 'location' },
            lualine_y = { --[['diagnostics', 'diff', 'branch',--]] },
            lualine_z = {  }
        }
    }
end

return {
    "nvim-lualine/lualine.nvim", 
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = config
}
