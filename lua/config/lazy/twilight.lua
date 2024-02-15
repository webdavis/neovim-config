return {
  "folke/twilight.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    vim.api.nvim_set_keymap(
      'n',
      '<leader>ti',
      ':<C-u>Twilight<CR>',
      { noremap = true, silent = true }
    )
  end
}
