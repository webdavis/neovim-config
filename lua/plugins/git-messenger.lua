return {
  "rhysd/git-messenger.vim",
  config = function()
    vim.keymap.set("n", "<leader>gm", "<cmd>GitMessenger<cr>", { desc = "git-messenger - open" })
    vim.keymap.set("n", "<leader>g0", "<cmd>GitMessengerClose<cr>", { desc = "git-messenger - close" })
  end,
}
