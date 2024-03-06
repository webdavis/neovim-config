return {
  "axieax/urlview.nvim",
  config = function()
    require("urlview").setup({})
    vim.keymap.set('n', '<leader>ur', "<cmd>UrlView<cr>", { noremap = true, desc = 'urlview - open selected URL in your browser' })
  end
}
