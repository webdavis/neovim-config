return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesj').setup({
      use_default_keymaps = false,
    })
    vim.keymap.set({'n'}, '<leader>jt', function() require('treesj').toggle() end, { noremap = true, desc = 'splitjoin - toggle'})
    vim.keymap.set({'n'}, '<leader>js', function() require('treesj').split() end, { noremap = true, desc = 'splitjoin - split'})
    vim.keymap.set({'n'}, '<leader>jj', function() require('treesj').join() end, { noremap = true, desc = 'splitjoin - join'})
  end,
}
