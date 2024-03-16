return {
  "j-hui/fidget.nvim",
  config = function()
    require("fidget").setup({
      notification = {
        window = {
          normal_hl = "TabLineFill",
          winblend = 50,
        },
      },
    })
    vim.notify = require("fidget.notification").notify
  end,
}
