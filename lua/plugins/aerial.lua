return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  },
  config = function()
    require("aerial").setup({
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
    })
    -- You probably also want to set a keymap to toggle aerial
    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
    require("telescope").load_extension("aerial")
    require("telescope").setup({
      extensions = {
        aerial = {
          -- Display symbols as <root>.<parent>.<symbol>
          show_nesting = {
            ["_"] = false, -- This key will be the default
            json = true, -- You can set the option for specific filetypes
            yaml = true,
          },
        },
      },
    })

    vim.api.nvim_set_keymap('n', '<leader>fa', '<cmd>Telescope aerial<cr>', { noremap = true, desc = 'Telescope Aerial Integration' })
  end
}
