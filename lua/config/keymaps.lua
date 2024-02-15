vim.g.mapleader = ' '

vim.api.nvim_set_keymap('n', '<C-s>',      '<cmd>write<cr><esc>', { noremap = true, silent = false, desc = 'Save file' })
vim.api.nvim_set_keymap('v', '<C-c>',      'y',                   { noremap = true, silent = true,  desc = 'Copy' })
vim.api.nvim_set_keymap('v', '<C-v>',      '"0p',                 { noremap = true, silent = true,  desc = 'Paste' })
vim.api.nvim_set_keymap('n', '<C-q>',      ':<C-u>quit<CR>',      { noremap = true, silent = true,  desc = 'Quickly quit the file'})
vim.api.nvim_set_keymap('n', '<leader>la',  '<cmd>Lazy<cr>',      { noremap = true, silent = true,  desc = 'Open Lazy' })
vim.api.nvim_set_keymap('n', '<leader>en',  '<cmd>enew<cr>',       { noremap = true, silent = true,  desc = 'New File' })
vim.api.nvim_set_keymap('n', '<leader>qq', '<cmd>qa<cr>',         { noremap = true, silent = true,  desc = 'Quit all' })
vim.api.nvim_set_keymap('v', '<',          '<gv',                 {                                 desc = 'Shift left' })
vim.api.nvim_set_keymap('v', '>',          '>gv',                 {                                 desc = 'Shift right' })
vim.api.nvim_set_keymap('n', '<leader>ns', '<cmd>ASToggle<cr>',   { noremap = true, silent = false, desc = 'Activate Autosave' })
vim.keymap.set({'n', 't', 'i', 'v'}, '<C-_>', '<cmd>ToggleTerm<cr>', { noremap = true, desc = 'Open floating terminal'} )
