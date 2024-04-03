return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "folke/neodev.nvim",
      "stevearc/overseer.nvim",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-plenary",
      "lawrence-laz/neotest-zig",
      "rcasia/neotest-bash",
    },
    config = function()
      require("neodev").setup({
        library = {
          plugins = { "neotest" },
          types = true,
        },
      })
      local neotest = require("neotest")
      neotest.setup({
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        library = { plugins = { "neotest" }, types = true },
        adapters = {
          require("neotest-vitest"),
          require("neotest-plenary").setup({
            min_init = "./scripts/minimal_init.lua",
          }),
          require("neotest-zig"),
          require("neotest-bash"),
        },
      })

      vim.keymap.set("n", "<leader>tn", function()
        neotest.run.run()
      end, { desc = "neotest - run nearest test" })

      vim.keymap.set("n", "<leader>tf", function()
        neotest.run.run(vim.fn.expand("%"))
      end, { desc = "neotest - run test file" })

      vim.keymap.set("n", "<leader>t;", function()
        neotest.run.run(vim.fn.getcwd())
      end, { desc = "neotest - run test suite" })

      vim.keymap.set("n", "<leader>tl", function()
        neotest.run.run_last()
      end, { desc = "neotest - run last test" })

      vim.keymap.set("n", "<leader>th", function()
        neotest.run.stop()
      end, { desc = "neotest - halt tests" })

      vim.keymap.set("n", "<leader>ts", function()
        neotest.summary.toggle()
      end, { desc = "neotest - toggle summary" })

      vim.keymap.set("n", "<leader>to", function()
        neotest.output.open({ enter = true, auto_close = true })
      end, { desc = "neotest - show output" })

      vim.keymap.set("n", "<leader>tp", function()
        neotest.output_panel.toggle()
      end, { desc = "neotest - toggle output panel" })

      vim.keymap.set("n", "<leader>tw", function()
        neotest.watch.toggle(vim.fn.expand("%"))
      end, { desc = "neotest - watch file (run on save)" })

      vim.keymap.set("n", "]t", function()
        neotest.jump.next()
      end, { desc = "neotest - goto next test" })

      vim.keymap.set("n", "[t", function()
        neotest.jump.next()
      end, { desc = "neotest - goto previous test" })
    end,
  },
}
