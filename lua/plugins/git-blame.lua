return {
  'f-person/git-blame.nvim',
  event = 'VeryLazy',
  config = function()
    vim.keymap.set({'n'}, '<C-g>bc', '<cmd>GitBlameCopySHA<cr>', { noremap = true, silent = false })
    vim.keymap.set({'n'}, '<C-g>bt', '<cmd>GitBlameToggle<cr>', { noremap = true, silent = false })
  end
}
