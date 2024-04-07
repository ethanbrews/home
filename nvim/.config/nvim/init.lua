vim.g.treesitter_plugin = true
vim.g.neorg_plugin = true

require('config.lazy')
require('config.options')
require('config.keymaps').init()
