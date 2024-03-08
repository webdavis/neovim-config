local M = {}

M.set_option = function(option, context_dict)
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

M.map = function(mode, lhs, rhs, desc, notify)
	local silent = (type(rhs) == "function" or not rhs:match("^:<C%-u>")) and true or false
	local options = { noremap = true, desc = desc, silent = silent }

	local callback
	if silent then
		callback = function()
			vim.cmd(rhs)
			if notify then
				vim.notify(desc, "info")
			end
		end

		vim.keymap.set(mode, lhs, callback, options)
	else
		vim.keymap.set(mode, lhs, rhs, options)
	end
end

return M
