return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require 'nvim-treesitter'
            local lang = {
                "java",
                "cpp",
                "json",
                "python",
                "javascript",
                "query",
                "typescript",
                "tsx",
                "rust",
                "zig",
                "yaml",
                "html",
                "css",
                "markdown",
                "markdown_inline",
                "bash",
                "lua",
                "vim",
                "vimdoc",
                "c",
                "dockerfile",
                "gitignore",
            }
            ts.install(lang)
            local filetypes = vim.iter(lang):map(vim.treesitter.language.get_filetypes):flatten():totable()
            vim.api.nvim_create_autocmd('FileType', {
                pattern = filetypes,
                callback = function()
                    vim.treesitter.start()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    }
}
