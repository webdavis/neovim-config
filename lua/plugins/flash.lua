return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    labels = "fghjklqwetuopzvbnm",
    modes = {
      char = {
        jump_labels = true
      }
    },
    label = {
      -- allow uppercase labels
      uppercase = true,
    -- add any labels with the correct case here, that you want to exclude
      exclude = "yCDX",
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>/", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "<leader>T", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter integration" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Flash Remote" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
