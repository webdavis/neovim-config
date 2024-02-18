return {
  "axieax/urlview.nvim",
  config = function()
    require("urlview").setup()
    vim.keymap.set('n', '<leader>ur', ":<C-u>UrlView<CR>", {noremap = true})
  end
}
