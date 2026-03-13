vim.opt.guicursor = "n:blinkon0"
-- for diagnostic border
vim.opt.winborder = "single"
-- tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.showtabline = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
-- sign column on left for errors
vim.opt.signcolumn = "yes"
-- prevent wrapping to next line
vim.opt.wrap = false
-- searching
vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.cursorcolumn = false

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.clipboard = "unnamedplus"
vim.cmd([[hi @lsp.type.number gui=italic]])
-- scrolling
vim.opt.scrolloff = 999
vim.o.sidescrolloff = 12


vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
