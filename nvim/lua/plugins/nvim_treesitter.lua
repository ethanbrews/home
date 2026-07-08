return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = "VeryLazy",
    config = function()
        require('nvim-treesitter').setup {
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            incremental_selection = {
                enable = true,
            },
            auto_install = true,
            ensure_installed = {
                'c',
                'cpp',
                'go',
                'lua',
                'python',
                'rust',
                'typescript',
                'cmake',
                'markdown',
                'bash',
                'markdown_inline',
            },
            compilers = { "clang" }
        }
    end
}
