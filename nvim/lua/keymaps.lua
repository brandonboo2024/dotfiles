local function pack_clean()
	local active_plugins = {}
	local unused_plugins = {}

	for _, plugin in ipairs(vim.pack.get()) do
		active_plugins[plugin.spec.name] = plugin.active
	end

	for _, plugin in ipairs(vim.pack.get()) do
		if not active_plugins[plugin.spec.name] then
			table.insert(unused_plugins, plugin.spec.name)
		end
	end

	if #unused_plugins == 0 then
		print("No unused plugins.")
		return
	end

	local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
	if choice == 1 then
		vim.pack.del(unused_plugins)
	end
end

local builtin = require("telescope.builtin")
local map = vim.keymap.set
local current = 1
vim.g.mapleader = " "

map("n", "<leader>-", pack_clean, { desc = "Clean unnecessary packages" })
map({ "n", "t" }, "<leader>t", "<Cmd>tabnew<CR>")
map({ "n", "t" }, "<leader>x", "<Cmd>tabclose<CR>")

for i = 1, 8 do
	map({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>")
end
map({ "n", "v", "x" }, "<leader>n", ":norm ", { desc = "ENTER NORM COMMAND." })
map({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Enter substitute mode in selection" })
map({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format current buffer" })
map({ "v", "x", "n" }, "<C-y>", '"+y', { desc = "System clipboard yank." })
map({ "n" }, "<leader>f", builtin.find_files, { desc = "Telescope live grep" })

function git_files() builtin.find_files({ no_ignore = true }) end

function grep() builtin.live_grep({ additional_args = { "-e" } }) end

map({ "n" }, "<leader>g", grep)
map({ "n" }, "<leader>sg", git_files)
map({ "n" }, "<leader>sb", builtin.buffers, { desc = "search buffers" })
map({ "n" }, "<leader>si", builtin.grep_string, { desc = "search for string" })
map({ "n" }, "<leader>sr", builtin.lsp_references, { desc = "LSP references" })
map({ "n" }, "<leader>sd", builtin.diagnostics, { desc = "Diagnostics for entire workspace" })
map({ "n" }, "<leader>sT", builtin.lsp_type_definitions, { desc = "Type Definitions" })
map({ "n" }, "<leader>ss", builtin.current_buffer_fuzzy_find, { desc = "Search in current buffer" })
map({ "n" }, "<leader>sc", builtin.git_bcommits, { desc = "Search git commits" })
map({ "n" }, "<leader>sk", builtin.keymaps, { desc = "Telescope for keymaps" })
map({ "n" }, "<leader>se", "<cmd>Telescope env<cr>", { desc = "Search environment variables" })
map({ "n" }, "<leader>sa", require("actions-preview").code_actions, { desc = "Code actions" })
map({ "n" }, "<M-n>", "<cmd>resize +2<CR>")
map({ "n" }, "<M-e>", "<cmd>resize -2<CR>")
map({ "n" }, "<M-i>", "<cmd>vertical resize +5<CR>")
map({ "n" }, "<M-m>", "<cmd>vertical resize -5<CR>")
map({ "n" }, "<leader>e", "<cmd>Oil<CR>")
map({ "n" }, "<C-q>", ":copen<CR>", { silent = true })
map({ "n" }, "<leader>w", "<Cmd>update<CR>", { desc = "Write the current buffer." })
map({ "n" }, "<leader>q", "<Cmd>:quit<CR>", { desc = "Quit the current buffer." })
map({ "n" }, "<leader>Q", "<Cmd>:wqa<CR>", { desc = "Quit all buffers and write." })

map("n", "<Tab>", ":bp<cr>")
map("n", "<S-Tab>", ":bprev<CR>")
map("n", "<leader>x", ":bd<cr>")

local function tmux_nav(cmd)
	return ("<cmd>packadd vim-tmux-navigator | <C-U>%s<cr>"):format(cmd)
end

local map = vim.keymap.set
map("n", "<C-h>", tmux_nav("TmuxNavigateLeft"), { silent = true })
map("n", "<C-j>", tmux_nav("TmuxNavigateDown"), { silent = true })
map("n", "<C-k>", tmux_nav("TmuxNavigateUp"), { silent = true })
map("n", "<C-l>", tmux_nav("TmuxNavigateRight"), { silent = true })
map("n", "<C-\\>", tmux_nav("TmuxNavigatePrevious"), { silent = true })
