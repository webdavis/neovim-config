return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-plenary",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-vitest"),
          require("neotest-plenary").setup({
            -- this is my standard location for minimal vim rc
            -- in all my projects
            min_init = "./scripts/tests/minimal.vim",
          }),
        }
      })

      vim.keymap.set("n", "<leader>tc", function() neotest.run.run() end, { desc = 'Run nearest' })
      vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = 'Run file' })
      vim.keymap.set("n", "<leader>ta", function() neotest.run.run(vim.loop.cwd()) end, { desc = 'Run all test files (workspace)' })
      vim.keymap.set("n", "<leader>tl", function() neotest.run.run_last() end, { desc = 'Run last test' })
      vim.keymap.set("n", "<leader>th", function() neotest.run.stop() end, { desc = 'Halt tests' })
      vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = 'Toggle summary' })
      vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true, auto_close = true }) end, { desc = 'Show output' })
      vim.keymap.set("n", "<leader>tO", function() neotest.output_panel.toggle() end, { desc = 'Toggle output panel' })
    end,
  },
}
