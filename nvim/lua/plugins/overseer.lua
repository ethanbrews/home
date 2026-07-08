return {
    "stevearc/overseer.nvim",
    -- Lazy-loaded: interactively via its commands/keys, and force-loaded at
    -- startup by a project-local .nvim.lua (require('lazy').load) when needed,
    -- so it costs nothing in other sessions.
    cmd = {
        "OverseerRun",
        "OverseerToggle",
        "OverseerOpen",
        "OverseerRunCmd",
        "OverseerQuickAction",
        "OverseerTaskAction",
        "OverseerInfo",
        "OverseerBuild",
    },
    keys = {
        { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer: toggle task list" },
        { "<leader>or", "<cmd>OverseerRun<cr>",    desc = "Overseer: run task" },
    },
    opts = {},
}
