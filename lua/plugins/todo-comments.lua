return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  config = function()
    local todo_comments = require("todo-comments")
    todo_comments.setup({
      keywords = {
        MARK = {
          icon = "🅼 ",
          color = "test",
          alt = {},
        },
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--no-ignore-vcs",
        },
      },
    })

    local map = require("config.custom_api").map

    local todo_keywords = {
      "BUG",
      "ERROR",
      "FAILED",
      "FIXIT",
      "FIXME",
      "HACK",
      "INFO",
      "ISSUE",
      "MARK",
      "NOTE",
      "OPTIM",
      "OPTIMIZE",
      "PASSED",
      "PERF",
      "PERFORMANCE",
      "TEST",
      "TESTING",
      "TODO",
      "WARN",
      "WARNING",
      "XXX",
    }

    map("n", "]w", function()
      todo_comments.jump_next({ keywords = todo_keywords })
    end, "Jump to next todo comment")

    map("n", "[w", function()
      todo_comments.jump_prev({ keywords = todo_keywords })
    end, "Jump to previous todo comment")

    vim.keymap.set("n", "<leader>fc", "<cmd>TodoTelescope<cr>", { desc = "find - todo comments" })
  end,
}
