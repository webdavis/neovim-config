return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim',
    'nvim-tree/nvim-web-devicons'
  },
  opts = {
    icons = {
      button = '×',
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = {enabled = true},
        [vim.diagnostic.severity.WARN] = {enabled = true},
        [vim.diagnostic.severity.INFO] = {enabled = true},
        [vim.diagnostic.severity.HINT] = {enabled = true},
      },
    },
    hide = {
      extensions = true,
      inactive = true,
    },
    gitsigns = {
      added = {enabled = true, icon = '+'},
      changed = {enabled = true, icon = '~'},
      deleted = {enabled = true, icon = '-'},
    },
  }
}
