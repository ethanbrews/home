local config = function()
    require("cscope_maps").setup {
        opts = {
            disable_maps = false,
            skip_input_prompt = false,
            prefix = "<Leader>c",
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
end

return {
    "dhananjaylatkar/cscope_maps.nvim",
    dependencies = {
        "folke/which-key.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = config
}
