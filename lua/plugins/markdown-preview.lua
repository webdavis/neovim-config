return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,
  config = function()
    vim.keymap.set({ 'n' }, '<leader>ms', '<cmd>MarkdownPreview<cr>')
    vim.keymap.set({ 'n' }, '<leader>mx', '<cmd>MarkdownStop<cr>')
    vim.keymap.set({ 'n' }, '<leader>mt', '<cmd>MarkdownPreviewToggle<cr>')
  end
}
