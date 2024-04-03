return {
  "rcarriga/nvim-notify",
  config = function()
    require("notify").setup({
      stages = "static",
      timeout = 2000,
    })
    -- vim.notify = require("notify")
  end,
}
