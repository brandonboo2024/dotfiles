vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = false
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 999

-- allows virtual editing in visual block 
-- (cursor can go past end of line.)
vim.opt.virtualedit = "block"
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- vim.keymap.set({"n", "v"}, "<leader>y", [["=y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])
