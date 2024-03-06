return {
  "folke/zen-mode.nvim",
  dependencies = {'folke/twilight.nvim'},
  opts = {
    -- twilight = { enabled = true },
    -- gitsigns = { enabled = false },
    -- tmux = { enabled = false },
  },
  config = function()
    vim.keymap.set("n", "<leader>z", function()
      require("zen-mode").setup {
        window = {
          width = 90,
          options = { }
        },
      }
      require("zen-mode").toggle()
      vim.wo.wrap = false
      vim.wo.number = true
      vim.wo.rnu = true
    end, { desc = 'zen-mode - toggle with twilight enabled' })

    vim.keymap.set("n", "<leader>Z", function()
      require("zen-mode").setup {
        window = {
          width = 80,
          options = { }
        },
      }
      require("zen-mode").toggle()
      vim.cmd('TwilightDisable')
      vim.wo.wrap = false
      vim.wo.number = false
      vim.wo.rnu = false
    end, { desc = 'zen-mode - toggle with tw=80 and twilight disabled' })
  end
}
