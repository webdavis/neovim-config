return {
  "unblevable/quick-scope",
  config = function()
    vim.g.qs_filetype_blacklist = { "gitcommit", "help" }

    local map = require("config.custom_api").map

    map("n", "<M-q>", function()
      vim.cmd("QuickScopeToggle")
      local notify = require("notify")
      if vim.g.qs_enable == 1 then
        notify("quick-scope - Enabled", vim.log.levels.INFO)
      else
        notify("quick-scope - Disabled", vim.log.levels.WARN)
      end
    end, "quickscope - toggle", false)

    vim.api.nvim_set_hl(0, "QuickScopePrimary", { fg = "#f5ca5e", bold = false, underline = true })
    vim.api.nvim_set_hl(0, "QuickScopeSecondary", { fg = "#fc0094", bold = false, underline = true })
  end,
}
