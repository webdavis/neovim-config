return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		modes = {
			search = {
				enabled = false,
			},
			char = {
				enabled = false,
				jump_labels = true,
			},
		},
		label = {
			-- allow uppercase labels
			uppercase = true,
		},
	},
  -- stylua: ignore
  keys = {
    { "<leader>/", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "flash - search" },
    { "gs", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "flash - treesitter integration" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "flash - remote" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "flash - toggle flash style search" },
  },
}
