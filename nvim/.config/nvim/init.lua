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

-- Plugins

local plugins = {
	{ "smoka7/hop.nvim", opts = {  } },
	{ "nvim-telescope/telescope.nvim", dependencies = { 'nvim-lua/plenary.nvim' } },
	{ "ThePrimeagen/harpoon", dependencies = { 'nvim-lua/plenary.nvim' } },
	{ "tpope/vim-fugitive" },
	{ "scrooloose/nerdcommenter" },
	{ "nvim-treesitter/nvim-treesitter" },
    {
          "olimorris/onedarkpro.nvim",
          priority = 1000, -- Ensure it loads first
    },
    {
      "dhananjaylatkar/cscope_maps.nvim",
      dependencies = {
        "folke/which-key.nvim", -- optional [for whichkey hints]
        "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
        "ibhagwan/fzf-lua", -- optional [for picker="fzf-lua"]
        "nvim-tree/nvim-web-devicons", -- optional [for devicons in telescope or fzf]
      },
      opts = {
        disable_maps = false, -- "true" disables default keymaps
        skip_input_prompt = false, -- "true" doesn't ask for input
        prefix = "<leader>c", -- prefix to trigger maps

        -- cscope related defaults
        cscope = {
          exec = "cscope",
          picker = "telescope",
          skip_picker_for_single_result = false,
          project_rooter = {
            enable = false,
            change_cwd = false
          }
        }
      }
    }
}

-- Basic Settings

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { "*.triage" },
    command = "setfiletype log"
})

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
vim.fn.matchadd('errorMsg', [[\s\+$]])
vim.opt.mouse = ""
vim.opt.termguicolors = true

-- Start plugin manager
require("lazy").setup(plugins)


-- Treesitter Enable

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'typescript', 'cmake', 'markdown', 'bash', 'markdown_inline' }
}


-- Colorscheme

require("onedarkpro").setup({ })

vim.cmd("colorscheme onedark")

-- Keybindings (Cscope)

require("cscope_maps").setup()


-- Keybindings (VimFugitive)

vim.keymap.set('n', 'gb', ':Git blame<CR>')


-- Keybindings (Hop)
vim.keymap.set('n', '<Leader>f', ':HopWord<CR>', { silent = true })

local hop = require('hop')
local directions = require('hop.hint').HintDirection

vim.keymap.set('', '<Leader>w', function()
    hop.hint_words({ direction = directions.AFTER_CURSOR, current_line_only = false })
end, {remap=true})

vim.keymap.set('', '<Leader>b', function()
    hop.hint_words({ direction = directions.BEFORE_CURSOR, current_line_only = false })
end, {remap=true})

-- Keybindings (Vim)

vim.keymap.set('n', 'tn', ':bnext<CR>')
vim.keymap.set('n', 'tp', ':bprevious<CR>')
vim.keymap.set('n', ';;', ':set list!<CR>', { silent = true })
vim.keymap.set('n', '<C-l>', ':noh<CR>:let @/ = ""<CR>', { nowait = true, silent = true })

-- Keybindings (Harpoon)

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



-- Keybindings (Telescope)

local telescope = require('telescope.builtin')
-- telescope.load_extension('harpoon')

vim.keymap.set('n', 'tl', telescope.buffers)
vim.keymap.set('n', 'tf', telescope.find_files)
vim.keymap.set('n', 'tq', telescope.help_tags)
vim.keymap.set('n', 'tg', telescope.live_grep)
vim.keymap.set('n', 'th', telescope.oldfiles)
vim.keymap.set('n', 't;', telescope.command_history)
vim.keymap.set('n', 'tt', telescope.tags)
vim.keymap.set('n', 'tm', telescope.marks)
vim.keymap.set('n', 'tq', telescope.registers)
vim.keymap.set('n', 't/', telescope.man_pages)

require "telescope".setup {
  defaults = {
    preview = {
      treesitter = false
    }
  }
}
