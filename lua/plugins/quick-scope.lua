return {
  "unblevable/quick-scope",
  config = function()
    vim.g.qs_filetype_blacklist = { "gitcommit" }
    vim.api.nvim_set_hl(0, 'QuickScopePrimary', { fg='#f5ca5e', bold = false, underline = true })
    vim.api.nvim_set_hl(0, 'QuickScopeSecondary', { fg='#fc0094', bold = false, underline = true })
  end,
}
