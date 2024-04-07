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

