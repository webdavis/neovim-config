return {
  "saifulapm/chartoggle.nvim",
  config = function()
    require("chartoggle").setup({
      leader = "<leader>",
      keys = { ",", ";", "." },
    })
  end,
}
