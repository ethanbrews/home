if (not vim.g.treesitter_plugin) then
    return {  }
end

local config = function()
    require('nvim-treesitter.configs').setup {
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'typescript', 'cmake', 'markdown', 'bash', 'markdown_inline' }
    }
end

return { 
    "nvim-treesitter/nvim-treesitter",
    config = config
}
