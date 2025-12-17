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
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
	{ src = "https://github.com/hrsh7th/cmp-buffer" },
})

require("nvim-highlight-colors").setup {}
require("bufferline").setup {}
require("lualine").setup()

-- auto complete setup
local cmp = require("cmp")
cmp.setup({
	preselect = cmp.PreselectMode.Item, -- <— preselect first item
	completion = { completeopt = "menu,menuone,noinsert" },
	window = { documentation = cmp.config.window.bordered() },
	mapping = cmp.mapping.preset.insert({
		["<CR>"]    = cmp.mapping.confirm({ select = false }),
		["<C-e>"]   = cmp.mapping.abort(),
		["<C-y>"]   = cmp.mapping.complete(), -- manual trigger if you want it
		["<C-n>"]   = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-p>"]   = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-f>"]   = cmp.mapping.scroll_docs(4),
		["<C-u>"]   = cmp.mapping.scroll_docs(-4),
		["<Tab>"]   = cmp.mapping(function(fallback)
			if cmp.visible() then cmp.select_next_item() else fallback() end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function()
			if cmp.visible() then cmp.select_prev_item() end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "path" },
		{ name = "buffer",  keyword_length = 3 },
	},
})

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
require("nvim-treesitter").install(ensure_installed)


vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

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
