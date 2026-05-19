local map = vim.keymap.set

vim.g.mapleader = " "
map("n", "<leader>cd", vim.cmd.Ex)
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>cp", ":%y+<CR>", { desc = "Copy All" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })



