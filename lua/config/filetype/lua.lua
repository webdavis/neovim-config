local function set_lua_filetype_options()
  vim.opt_local.shiftwidth = 2
  vim.opt_local.tabstop = 2
  vim.opt_local.softtabstop = 2
  vim.opt_local.expandtab = true
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'lua'},
  group = augroup("lua"),
  callback = set_lua_filetype_options,
})
