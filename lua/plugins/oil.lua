return {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function ()
    require("oil").setup({
      default_file_explorer = false,
      columns = {
        "icon",
      }
    })
    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "oil - open parent directory" })
  end
}
