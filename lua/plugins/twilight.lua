return {
  "folke/twilight.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>y', '<cmd>Twilight<cr>', { noremap = true, silent = true, desc = 'twilight - toggle' })
  end
}
