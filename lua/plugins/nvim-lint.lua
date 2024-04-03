return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      swift = { "swiftlint" },
      ansible = { "ansible_lint" },
      yaml = { "yamllint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    local events = { "BufEnter", "BufWritePost", "BufReadPost" }

    vim.api.nvim_create_autocmd(events, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    local map = require("config.custom_api").map

    map("n", "<leader>cl", function()
      require("lint").try_lint()
      local full_path = vim.api.nvim_buf_get_name(0)
      local file_name_only = vim.fn.fnamemodify(full_path, ":t")
      vim.notify("nvim-lint - linting " .. file_name_only, vim.log.levels.INFO)
    end, "nvim-lint - lint current file", false)
  end,
}
