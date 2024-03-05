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
	{ "tpope/vim-fugitive" },
	{ "scrooloose/nerdcommenter" }
}

-- Basic Settings

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { "*.triage" },
    command = "setfiletype log"
})

--vim.opt.nocompatible = true
vim.opt.nu = true
vim.opt.rnu = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
--vim.opt.syntax = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.ttyfast = true
vim.opt.wildmode = { 'longest', 'list' }
vim.opt.listchars = { eol = '$', tab = '>>', trail = '•' }
vim.opt.mouse = ""

-- Start plugin manager
require("lazy").setup(plugins)


-- Keybindings (VimFugitive)

vim.keymap.set('n', 'gb', ':Git blame<CR>')


-- Keybindings (Hop)
vim.keymap.set('n', '<Leader>w', ':HopWord<CR>', { silent = true })

-- Keybindings (Vim)

vim.keymap.set('n', 'tn', ':bnext<CR>')
vim.keymap.set('n', 'tp', ':bprevious<CR>')
vim.keymap.set('n', ';;', ':set list!<CR>', { silent = true })
vim.keymap.set('n', '<C-l>', ':noh<CR>:let @/ = ""<CR>', { nowait = true, silent = true })


-- Keybindings (Telescope)

local telescope = require('telescope.builtin')

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

--[[ telescope.defaults.file_ignore_patterns = {
    "vendor/*",
    "%.lock",
    "__pycache__/*",
    "%.sqlite3",
    "%.ipynb",
    "node_modules/*",
    "%.jpg",
    "%.jpeg",
    "%.png",
    "%.svg",
    "%.otf",
    "%.ttf",
    ".git/",
    "%.webp",
    ".dart_tool/",
    ".github/",
    ".gradle/",
    ".idea/",
    ".settings/",
    ".vscode/",
    "__pycache__/",
    "build/",
    "env/",
    "gradle/",
    "node_modules/",
    "target/",
    "%.pdb",
    "%.dll",
    "%.class",
    "%.exe",
    "%.cache",
    "%.ico",
    "%.pdf",
    "%.dylib",
    "%.jar",
    "%.docx",
    "%.met",
    "smalljre_*/*",
    ".vale/",
    "%.burp",
    "%.mp4",
    "%.mkv",
    "%.rar",
    "%.zip",
    "%.7z",
    "%.tar",
    "%.bz2",
    "%.epub",
    "%.flac",
    "%.tar.gz",
  }
]]
