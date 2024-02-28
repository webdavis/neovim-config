local function set_custom_filetype_options()
  vim.opt_local.shiftwidth = 2
  vim.opt_local.tabstop = 2
  vim.opt_local.softtabstop = 2
  vim.opt_local.expandtab = true
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'lua', 'bash', 'sh',},
  group = augroup("custom_filetype"),
  callback = set_custom_filetype_options,
})
