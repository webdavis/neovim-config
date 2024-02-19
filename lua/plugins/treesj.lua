return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesj').setup({
      use_default_keymaps = true,
    })
    vim.keymap.set({'n'}, '<leader>K', function() require('treesj').toggle() end, { noremap = true })
    vim.keymap.set({'n'}, '<leader>S', function() require('treesj').split() end, { noremap = true })
    vim.keymap.set({'n'}, '<leader>J', function() require('treesj').join() end, { noremap = true })
  end,
}