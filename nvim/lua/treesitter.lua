local ensure_installed = {
	"java",
	"cpp",
	"json",
	"python",
	"javascript",
	"typescript",
	"tsx",
	"rust",
	"zig",
	"yaml",
	"html",
	"css",
	"bash",
	"dockerfile",
	"gitignore",
	"typst",
}


require("nvim-treesitter").install(ensure_installed)
local filetypes = vim.iter(ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()


-- enable indentation and highlighting
vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function(ev)
		vim.treesitter.start(ev.buf)
		require 'nvim-treesitter'.indentexpr()
	end,
})
