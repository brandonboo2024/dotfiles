vim.opt_local.makeprg = "bash clang++ % -std=c++20 -Wall -o %:r"

vim.opt.errorformat = "%f:%l:%m"

vim.opt.makeef = ""

vim.keymap.set("n", "<leader>r", ":!./%:r<CR>", { desc = "Run compiled program" })
