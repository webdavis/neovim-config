return {
  'rhysd/git-messenger.vim',
  config = function()
    vim.keymap.set('n', '<C-g>k','<cmd>GitMessenger<cr>', { desc = 'git - open git-messenger' })
    vim.keymap.set('n', '<C-g>0','<cmd>GitMessengerClose<cr>', { desc = 'git - close git-messenger' })
  end
}
