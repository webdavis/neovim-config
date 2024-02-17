vim.g.mapleader = ' '

vim.api.nvim_set_keymap('n', '<C-s>',      '<cmd>write<cr><esc>', { noremap = true, silent = false, desc = 'Save file' })
vim.api.nvim_set_keymap('n', '<C-q>',      ':<C-u>quit<CR>',      { noremap = true, silent = true,  desc = 'Quickly quit the file'})
vim.api.nvim_set_keymap('n', '<leader>la',  '<cmd>Lazy<cr>',      { noremap = true, silent = true,  desc = 'Open Lazy' })
vim.api.nvim_set_keymap('n', '<leader>en',  '<cmd>enew<cr>',       { noremap = true, silent = true,  desc = 'New File' })
vim.api.nvim_set_keymap('n', '<leader>qq', '<cmd>qa<cr>',         { noremap = true, silent = true,  desc = 'Quit all' })
vim.api.nvim_set_keymap('v', '<',          '<gv',                 {                                 desc = 'Shift left' })
vim.api.nvim_set_keymap('v', '>',          '>gv',                 {                                 desc = 'Shift right' })

-- https://github.com/pocco81/auto-save.nvim
vim.api.nvim_set_keymap('n', '<leader>ns', '<cmd>ASToggle<cr>',   { noremap = true, silent = false, desc = 'Activate Autosave' })
vim.keymap.set({'n', 't', 'i', 'v'}, '<C-_>', '<cmd>ToggleTerm<cr>', { noremap = true, desc = 'Open floating terminal'} )

-- Copy, Cut, Paste clipboard integration.
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { noremap = true, desc = "Copy to clipboard" })
-- vim.keymap.set({ "n", "v" }, "<C-x>", '"+x', {  noremap = true, desc = "Cut to clipboard" })
vim.keymap.set({ "n", "v" }, "<C-v>", '"+gP', { noremap = true, desc = "Paste from clipboard" })
vim.keymap.set({ "i", "t" }, "<C-v>", '<esc>"+gP', { noremap = true, desc = "Paste from clipboard" })

-- Better up and down keys when there is line wrapping.
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Resize windows.
vim.keymap.set("n", "<C-Up>", ":resize +2<cr>", { noremap = true, desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<cr>", { noremap = true, desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<cr>", { noremap = true, desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<cr>", { noremap = true, desc = "Increase window width" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", { noremap = true, expr = true, desc = "Next search result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { noremap = true, expr = true, desc = "Next search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { noremap = true, expr = true, desc = "Next search result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward]", { noremap = true, expr = true, desc = "Prev search result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { noremap = true, expr = true, desc = "Prev search result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { noremap = true, expr = true, desc = "Prev search result" })
