-- Disable neorg here...

local neorg_enabled = true 

-- Plugin Manager Setup

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{ "smoka7/hop.nvim" },
	{ "nvim-telescope/telescope.nvim", dependencies = { 'nvim-lua/plenary.nvim' } },
	{ "ThePrimeagen/harpoon", dependencies = { 'nvim-lua/plenary.nvim' } },
	{ "tpope/vim-fugitive" },
	{ "scrooloose/nerdcommenter" },
	{ "nvim-treesitter/nvim-treesitter" },
	{ "preservim/nerdtree" },
    { "olimorris/onedarkpro.nvim" },
    {
      "dhananjaylatkar/cscope_maps.nvim",
      dependencies = {
        "folke/which-key.nvim", 
        "nvim-telescope/telescope.nvim", 
        "nvim-tree/nvim-web-devicons",
      }
    },
    { "dhruvasagar/vim-table-mode" },
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } }   
}

if (neorg_enabled) then
    table.insert(plugins, {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = true
    })
    table.insert(plugins, {
        "nvim-neorg/neorg",
        dependencies = { "luarocks.nvim" },
        lazy = false,
        version = "*",
        config = true,
    })
end

-- Basic Settings

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { "*.triage" },
    command = "setfiletype log"
})
vim.api.nvim_create_autocmd({ 'VimLeave' }, {
    pattern = { "*" },
    command = "set guicursor=a:ver5-blinkon2-blinkoff1"
});

vim.api.nvim_create_user_command('Vb', 'normal! <C-v>', {})

vim.opt.nu = true
vim.opt.rnu = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.ttyfast = true
vim.opt.wildmode = { 'longest', 'list' }
vim.opt.listchars = { eol = '$', tab = '>>', trail = '•' }
vim.opt.mouse = ""
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.fn.matchadd('errorMsg', [[\s\+$]]) -- Highlight trailing whitespace as an error
vim.opt.shortmess:append("S")
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevel = 99
vim.opt.wrapscan = false

vim.keymap.set('n', 'tn', ':bnext<CR>')
vim.keymap.set('n', 'tp', ':bprevious<CR>')
vim.keymap.set('n', ';;', ':set list!<CR>', { silent = true })  -- Toggle whitespace highlighting
vim.keymap.set('n', '<C-l>', ':noh<CR>:let @/ = ""<CR>', { nowait = true, silent = true }) -- Clear search
vim.keymap.set('n', ',,', ':set nu!<CR>:set rnu!<CR>', { nowait = true, silent = true }) -- Toggle line numbers


-- Start plugin manager
require("lazy").setup(plugins)


-- Treesitter

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'typescript', 'cmake', 'markdown', 'bash', 'markdown_inline' }
}


-- Colorscheme

require("onedarkpro").setup({
    highlights = {
        CursorLine = { bg = "#353a45" },
        CursorLineNR = { fg = "#dcc7a0" },
        HopNextKey = { fg = "#67b0ff", bg = "#414858" },
        HopNextKey1 = { fg = "#ffdd88", bg = "#414858" },
        HopNextKey2 = { fg = "#ccb06c", bg = "#414858" },
        Search = { underline = true, fg = "#e5c07b", bg = "#414858" }
    }
})

vim.cmd("colorscheme onedark")


-- Cscope

require("cscope_maps").setup {
    opts = {
        disable_maps = false, 
        skip_input_prompt = false,
        prefix = "<leader>c", -- prefix to trigger maps

        cscope = {
            exec = "cscope",
            picker = "telescope",
            skip_picker_for_single_result = true,
            project_rooter = {
                enable = false,
                change_cwd = false
            }
        }
    }
}


-- LuaLine

function llmodeformat(str)
    local mappingTable = {
        ["NORMAL"] = "N",
        ["INSERT"] = "I",
        ["COMMAND"] = "C",
        ["VISUAL"] = "V",
        ["V-BLOCK"] = "B",
    }

    if mappingTable[str] then
        return mappingTable[str]
    else
        return str
    end
end

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
        lualine_a = { { 'mode', fmt = llmodeformat } },
        lualine_b = {  },
        lualine_c = {'filename'},

        lualine_x = { 'progress', 'location' },
        lualine_y = { --[['diagnostics', 'diff', 'branch',--]] },
        lualine_z = {  }
    }
}


-- VimFugitive

vim.keymap.set('n', 'gb', ':Git blame<CR>')


-- Hop

local hop = require('hop')
hop.setup()
local directions = require('hop.hint').HintDirection

vim.keymap.set('', '<Leader>f', function()
    hop.hint_words({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, { remap = true })

vim.keymap.set('', '<Leader>F', function()
    hop.hint_words({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, { remap = true })

vim.keymap.set('', '<Leader>w', function()
    hop.hint_words({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, { remap = true })


-- Harpoon

local harpoon = require('harpoon')
harpoon.setup({
    global_settings = {
        -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
        save_on_toggle = false,
        -- saves the harpoon file upon every change. disabling is unrecommended.
        save_on_change = true,
        -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
        enter_on_sendcmd = false,
        -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
        tmux_autoclose_windows = false,
        -- filetypes that you want to prevent from adding to the harpoon list menu.
        excluded_filetypes = { "harpoon" },
        -- set marks specific to each git branch inside git repository
        mark_branch = false,
        -- enable tabline with harpoon marks
        tabline = false,
        tabline_prefix = "   ",
        tabline_suffix = "   ",
    }
})

vim.api.nvim_create_user_command('Rf', function()
    require("harpoon.mark").add_file()
end, {})

vim.keymap.set('n', 'tr', function()
    require("harpoon.ui").toggle_quick_menu()
end, { silent = true })


-- Telescope

local telescope = require('telescope')
local ts_builtin = require('telescope.builtin')
telescope.load_extension('harpoon')

vim.keymap.set('n', 'tl', ts_builtin.buffers)
vim.keymap.set('n', 'tf', ts_builtin.find_files)
vim.keymap.set('n', 'tq', ts_builtin.help_tags)
vim.keymap.set('n', 'tg', ts_builtin.live_grep)
vim.keymap.set('n', 'th', ts_builtin.oldfiles)
vim.keymap.set('n', 't;', ts_builtin.command_history)
vim.keymap.set('n', 'tt', ts_builtin.tags)
vim.keymap.set('n', 'tm', ts_builtin.marks)
vim.keymap.set('n', 'tq', ts_builtin.registers)
vim.keymap.set('n', 't/', ts_builtin.man_pages)
vim.keymap.set('n', 'tr', telescope.extensions.harpoon.marks)

telescope.setup {
  defaults = {
    preview = {
      treesitter = false
    }
  }
}

-- vim-table-mode

vim.keymap.set('n', 'mt', ':TableModeToggle<CR>')

-- Neorg

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
