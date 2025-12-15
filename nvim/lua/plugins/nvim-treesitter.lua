return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                highlight = { enable = true },
                indent = { enable = true },
                autotag = { enable = true },
                ensure_installed = { "lua", "vim", "vimdoc", "bash", "json", "python", "javascript", "typescript", "tsx", "html", "css", "c", "cpp", "rust", "zig", "yaml", "dockerfile", "gitignore", "markdown", "markdown_inline", "query", "java" },
                auto_install = false,
                sync_install = false,
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                        },
                    },
                },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {},
    },
}
