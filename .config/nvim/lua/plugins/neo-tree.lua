return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
        { "<leader>e", ":Neotree toggle<CR>", desc = "Toggle file explorer" },
        { "<leader>E", ":Neotree reveal<CR>", desc = "Reveal current file" },
    },
    opts = {
        close_if_last_window = false,
        default_source = "filesystem",
        window = {
            width = 35,
        },
        filesystem = {
            follow_current_file = {
                enabled = true,
            },
            use_libuv_file_watcher = true,
            filtered_items = {
                hide_dotfiles = false,
                hide_gitignored = false,
            },
        },
    },
}
