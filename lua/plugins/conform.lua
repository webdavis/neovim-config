return {
	"stevearc/conform.nvim",
	event = { "VeryLazy" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "conform - format buffer",
		},
	},
	init = function()
		vim.o.formatexpr = 'v:lua.require("conform").formatexpr()'
	end,

	config = function()
		require("conform").setup({
			formatters_by_ft = {
				c = { "clang_format" },
				lua = { "stylua" },
				python = { "isort", "black" },
				javascript = { { "prettierd", "prettier" } },
				json = { "jq" },
				just = { "just" },
				markdown = { "mdformat" },
				nix = { "nixfmt" },
				zig = { "zigfmt" },
				["_"] = { "trim_whitespace" },
				["*"] = { "typos" },
			},
			formatters = {
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { timeout_ms = 500, lsp_fallback = true }
			end,
		})

		-- ConformEnable! will enable formatting just for current buffer.
		vim.api.nvim_create_user_command("ConformEnable", function(args)
			(args.bang and vim.b or vim.g)["disable_autoformat"] = false
		end, { desc = "conform - enable autoformat on save", bang = true })

		-- ConformDisable! will disable formatting just for current buffer.
		vim.api.nvim_create_user_command("ConformDisable", function(args)
			(args.bang and vim.b or vim.g)["disable_autoformat"] = true
		end, { desc = "conform - disable format on save", bang = true })

		vim.keymap.set(
			"n",
			"<leader>ce",
			"<cmd>ConformEnable<cr>",
			{ desc = "conform - enable format on save (global)" }
		)

		vim.keymap.set(
			"n",
			"<leader>cE",
			"<cmd>ConformEnable!<cr>",
			{ desc = "conform - enable format on save (buffer)" }
		)

		vim.keymap.set(
			"n",
			"<leader>cd",
			"<cmd>ConformDisable<cr>",
			{ desc = "conform - disable format on save (global)" }
		)

		vim.keymap.set(
			"n",
			"<leader>cD",
			"<cmd>ConformDisable!<cr>",
			{ desc = "conform - disable format on save (buffer)" }
		)
	end,
}

-- javascript = { { "prettierd", "prettier" } },
