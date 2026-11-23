local map = vim.keymap.set

vim.g.mapleader = " "
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>cp", ":%y+<CR>", { desc = "Copy All" })
map("n", "<leader>p", "\"+p", { desc = "Paste" })
map("n", "<leader>c", "\"+y", { desc = "Copy" })
map("n", "<leader>ld", function()
    vim.diagnostic.open_float()
end, { desc = "Line diagnostic" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })



