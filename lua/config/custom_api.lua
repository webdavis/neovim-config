set_option = function(option, context_dict)
	for k, v in pairs(context_dict) do
		if k == "o" then
			vim.api.nvim_set_option(option, v)
		end
		if k == "bo" then
			vim.api.nvim_buf_set_option(vim.fn.bufnr(), option, v)
		end
		if k == "wo" then
			vim.api.nvim_win_set_option(0, option, v)
		end
	end
end

map = function(mode, lhs, rhs, desc)
	local silent = (type(rhs) == "function" or rhs:match("<cr>$")) and true or false

	local options = { noremap = true, desc = desc, silent = silent }

	vim.keymap.set(mode, lhs, rhs, options)
end
