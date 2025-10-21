vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })

vim.api.nvim_create_autocmd({ 'VimLeave' }, {
    pattern = { "*" },
    command = "set guicursor=a:ver5-blinkon2-blinkoff1"
});

vim.api.nvim_create_user_command('Vb', 'normal! <C-v>', {})

vim.api.nvim_set_keymap('n', 'tn', ':bn<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'tp', ':bp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'td', ':bd<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>di", function()
    local config = vim.diagnostic.config()
    vim.diagnostic.config({ virtual_text = not config.virtual_text })
end, { desc = "Toggle diagnostic virtual lines" })

vim.g.mapleader = "\\"
vim.g.maplocalleader = " "
vim.opt.nu = true
vim.opt.rnu = false
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
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.fn.matchadd('errorMsg', [[\s\+$]]) -- Highlight trailing whitespace as an error
vim.opt.shortmess:append("S")
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false
vim.opt.foldlevel = 99
vim.opt.wrapscan = false
vim.opt.clipboard = 'unnamed' -- Use system clipboard
vim.opt.signcolumn = "yes"
