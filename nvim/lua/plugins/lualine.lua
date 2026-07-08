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

-- Per-nvim-instance state file for the Claude Code status indicator.
-- Exported into the environment so the Claude terminal (and its hooks)
-- inherit it; the hooks in ~/.claude/settings.json write 'active'/'waiting'
-- here, and the component below reads it back. Unique per nvim PID so
-- multiple windows/projects never clobber each other.
vim.env.CLAUDE_NVIM_STATE = vim.env.CLAUDE_NVIM_STATE
    or ('/tmp/claude-nvim-' .. vim.fn.getpid() .. '.status')

-- True only once a Claude terminal has been opened in THIS session.
-- coder/claudecode.nvim runs the bare `claude` CLI in a terminal buffer
-- (e.g. term://.../claude), so match a terminal buffer whose name contains
-- 'claude'. Restricting to buftype 'terminal' avoids false positives from
-- editing files like claude.lua.
local function claude_invoked()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b)
            and vim.bo[b].buftype == 'terminal'
            and vim.api.nvim_buf_get_name(b):match('claude') then
            return true
        end
    end
    return false
end

-- 'active' | 'waiting' | nil (nil => not invoked this session => hidden).
local function claude_state()
    if not claude_invoked() then
        return nil
    end
    local f = vim.env.CLAUDE_NVIM_STATE and io.open(vim.env.CLAUDE_NVIM_STATE, 'r')
    if not f then
        return 'waiting'
    end
    local s = (f:read('*a') or ''):gsub('%s+', '')
    f:close()
    return s == 'active' and 'active' or 'waiting'
end

local function claude_label()
    return claude_state() and 'C' or ''
end

local claude_colors = {
    active = { fg = '#1b1713', bg = '#98c379', gui = 'bold' },  -- green: Claude is working
    waiting = { fg = '#1b1713', bg = '#e5c07b', gui = 'bold' }, -- amber: waiting on you
}

local function claude_color()
    return claude_colors[claude_state()]
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
            lualine_y = { 'diagnostics', 'diff', 'branch' },
            lualine_z = { { claude_label, color = claude_color } }
        }
    }
end

return {
    "nvim-lualine/lualine.nvim", 
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = config
}
