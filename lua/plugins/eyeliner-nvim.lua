return {
	"jinh0/eyeliner.nvim",
	config = function()
		require("eyeliner").setup({
			highlight_on_key = false, -- show highlights only after keypress
			dim = false, -- dim all other characters if set to true (recommended!)
		})

    vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg='#f5ca5e', bold = false, underline = true })
    vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg='#fc0094', underline = true })
	end,
}
