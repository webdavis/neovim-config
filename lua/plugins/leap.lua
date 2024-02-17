return {
  "ggandor/leap.nvim",
  enabled = true,
  config = function()
    vim.keymap.set('n', '<leader>s', '<Plug>(leap-from-window)', {noremap = true})
  end,
}
