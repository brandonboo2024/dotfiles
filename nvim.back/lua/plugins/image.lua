return {
    {
        "3rd/image.nvim",
        build = false,
        event = "VeryLazy",
        opts = {
            backend = "kitty",
            integrations = {
                markdown = { enabled = true },
        }
    }
    },
    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
            -- add options here
            -- or leave it empty to use the default settings
            default = {
                -- default image path
                dir_path = "././pasted_images",
                -- template for the image path
                template = ".image $FILE_PATH",
            },
        },
        keys = {
            -- suggested keymap
            { "<leader>i", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
        },
    },
    {
        "nvim-tree/nvim-web-devicons", opts = {}
    }
}
