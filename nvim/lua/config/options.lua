vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })

vim.api.nvim_create_user_command('Vb', 'normal! <C-v>', {})

vim.api.nvim_set_keymap('n', 'tn', ':bn<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'tp', ':bp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'td', ':bd<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>di", function()
    local config = vim.diagnostic.config()
    vim.diagnostic.config({ virtual_text = not config.virtual_text })
end, { desc = "Toggle diagnostic virtual lines" })

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
-- Faint background over trailing whitespace, always on (independent of `list`).
-- Defined as its own group so it stays subtle; a colorscheme load clears custom
-- groups, so (re)define it on ColorScheme as well as now. When `list` is on
-- (the "explicit" mode toggled by <leader>l) it brightens to stand out.
local function set_trailing_ws_hl()
    if vim.opt.list:get() then
        vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#8a4a4a", ctermbg = 131, bold = true })
    else
        vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#31353d", ctermbg = 237 })
    end
end
set_trailing_ws_hl()
-- <leader>l flips the "explicit" mode: listchars markers on/off, and the
-- trailing-whitespace highlight dim <-> bright in step.
vim.keymap.set("n", "<leader>l", function()
    vim.opt.list = not vim.opt.list:get()
    set_trailing_ws_hl()
end, { desc = "Toggle listchars + brighten trailing whitespace" })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("TrailingWhitespaceHl", { clear = true }),
    callback = set_trailing_ws_hl,
})
-- matchadd() is window-local, so (re)apply it for every window rather than only
-- the one open at startup.
vim.api.nvim_create_autocmd({ "VimEnter", "WinNew", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("TrailingWhitespace", { clear = true }),
    callback = function()
        if not vim.w.trailing_ws_match then
            vim.w.trailing_ws_match = vim.fn.matchadd("TrailingWhitespace", [[\s\+$]])
        end
    end,
})
vim.opt.shortmess:append("S")
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false
vim.opt.foldlevel = 99
vim.opt.wrapscan = false
vim.opt.clipboard = 'unnamed' -- Use system clipboard
vim.opt.signcolumn = "yes"

-- Enabled so I can put a .nvim.lua in a project root for formatting options
vim.o.exrc = true        -- allow .nvim.lua or .exrc per project
vim.o.secure = true      -- only run safe commands
