return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		{
			"s1n7ax/nvim-window-picker",
			version = "2.*",
			config = function()
				require("window-picker").setup({
					filter_rules = {
						include_current_win = false,
						autoselect_one = true,
						-- filter using buffer options
						bo = {
							-- if the file type is one of following, the window will be ignored
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							-- if the buffer type is one of following, the window will be ignored
							buftype = { "terminal", "quickfix" },
						},
					},
				})
			end,
		},
	},
	config = function()
		require("neo-tree").setup({
			popup_border_style = "rounded",
			enable_git_status = true,
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.cmd([[ setlocal relativenumber ]])
					end,
				},
			},
			default_component_configs = {
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				git_status = {
					symbols = {
						-- Change type
						added = "A", -- or "✚", but this is redundant info if you use git_status_colors on the name
						modified = "M", -- or "", but this is redundant info if you use git_status_colors on the name
						deleted = "D", -- this can only be used in the git_status source
						renamed = "R", -- this can only be used in the git_status source
						-- Status type
						untracked = "",
						ignored = "I",
						unstaged = "U",
						staged = "S",
						conflict = "C",
					},
				},
			},
			filesystem = {
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = false,
					never_show = {
						".DS_Store",
						"thumbs.db",
					},
				},
				hijack_netrw_behavior = "open_current",
			},
			git_status = {
				window = {
					position = "float",
				},
			},
		})

		local map = require("config.custom_api").map

		map("n", "<M-n>", "<cmd>Neotree toggle<cr>", "neotree - toggle")
		map("n", "<leader>ns", "<cmd>Neotree show<cr>", "neotree - show")
		map("n", "<leader>nn", "<cmd>Neotree focus<cr>", "neotree - focus")
		map("n", "<leader>nc", "<cmd>Neotree reveal current<cr>", "neotree - focus on current file (buffer)")
		map("n", "<leader>nr", "<cmd>Neotree reveal<cr>", "neotree - focus on current file (sidebar)")
		map("n", "<leader>nq", "<cmd>Neotree close<cr>", "neotree - close")
		map("n", "<leader>ng", "<cmd>Neotree git_status<cr>", "neotree - git status (floating window)")
		map("n", "<leader>nG", ":<C-u>Neotree git_base=", "neotree - set git base to compare to")
	end,
}
