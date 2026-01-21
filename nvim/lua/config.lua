-- package manager with native pack
vim.pack.add({
	-- CORE STUFF
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/LinArcX/telescope-env.nvim" },
	{ src = "https://github.com/aznhe21/actions-preview.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	-- Additional things like file picking, oil, lualine etc
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/ThePrimeagen/harpoon",                   name = "harpoon", version = "harpoon2" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
	{ src = "https://github.com/brenoprata10/nvim-highlight-colors" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	-- Autocomplete
	{ src = "https://github.com/Saghen/blink.cmp",                       name = "blink",   version = vim.version.range("1.*") },
	{ src = "https://github.com/sar/friendly-snippets.nvim" },
	-- comments and tmux and autopairs
	{ src = "https://github.com/numToStr/Comment.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	-- colorscheme
	{ src = "https://github.com/vague2k/vague.nvim" },
})

require("nvim-highlight-colors").setup {}
require("bufferline").setup {}
require("lualine").setup({})
require("nvim-autopairs").setup {}
-- comment.nvim
require("Comment").setup({
})

-- auto complete setup
local blink_opts = {
	keymap = { preset = "default" },
	appearance = {
		nerd_font_variant = "mono"
	},
	completion = { documentation = { auto_show = false } },
	sources = {
		default = { "lsp", "path", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" }
}
vim.list_extend(blink_opts.sources.default, { "snippets" })

require("blink.cmp").setup(blink_opts)

require("oil").setup({
	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
		autosave_changes = true,
	},
	columns = {
		"permissions",
		"icon",
	},
	float = {
		max_width = 0.7,
		max_height = 0.6,
		border = "rounded",
	},
})

-- see plugin/lsp.lua for additional configs
vim.lsp.enable({
	"lua_ls",
	"cssls",
	"ts_ls",
	"zls",
	"nil",
	"rust_analyzer",
	"clangd",
	"jsonls",
	"pylsp",
	"jdtls",
})

-- see treesitter.lua for setup

local telescope = require("telescope")
telescope.setup({
	defaults = {
		preview = { treesitter = false },
		color_devicons = true,
		sorting_strategy = "ascending",
		borderchars = {
			"", -- top
			"", -- right
			"", -- bottom
			"", -- left
			"", -- top-left
			"", -- top-right
			"", -- bottom-right
			"", -- bottom-left
		},
		path_displays = { "smart" },
		layout_config = {
			height = 100,
			width = 400,
			prompt_position = "top",
			preview_cutoff = 40,
		}
	}
})
telescope.load_extension("ui-select")

require("actions-preview").setup {
	backend = { "telescope" },
	extensions = { "env" },
	telescope = vim.tbl_extend(
		"force",
		require("telescope.themes").get_dropdown(), {}
	)
}
