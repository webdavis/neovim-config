return {
  "Bekaboo/deadcolumn.nvim",
  config = function()
    require("deadcolumn").setup({
      scope = "buffer",
      modes = function(mode)
        return mode:find("^[nictRss\x13]") ~= nil
      end,
      extra = {
        follow_tw = "+1",
      },
    })
  end,
}
