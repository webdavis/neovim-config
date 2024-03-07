return {
	"tpope/vim-fugitive",
	dependencies = { "tpope/vim-rhubarb" },
	config = function()
		vim.keymap.set("n", "<C-g>s", vim.cmd.Git, { noremap = true, desc = "git status" })
		vim.keymap.set("n", "<C-g>a", "<cmd>Gwrite<cr>", { noremap = true, desc = "git add" })

		vim.keymap.set("n", "<C-g>cf", "<cmd>Git commit %<cr>", { noremap = true, desc = "commit current file" })
		vim.keymap.set(
			"n",
			"<C-g>cc",
			"<cmd>Git commit<cr>",
			{ noremap = true, desc = "commit everything in staging area" }
		)
		vim.keymap.set(
			"n",
			"<C-g>cv",
			"<cmd>Git commit --verbose<cr>",
			{ noremap = true, desc = "verbose commit (show all changes in buffer)" }
		)
		vim.keymap.set("n", "<C-g>ca", "<cmd>Git commit --amend<cr>", { noremap = true, desc = "amend last commit" })
		vim.keymap.set(
			"n",
			"<C-g>cn",
			"<cmd>Git commit --amend --no-edit<cr>",
			{ noremap = true, desc = "amend commit without editing the message" }
		)

		vim.keymap.set("n", "<C-g>pr", function()
			vim.cmd.Git("pull --rebase")
		end, { noremap = true, desc = "pull and rebase" })
		vim.keymap.set("n", "<C-g>pp", function()
			vim.cmd.Git("push")
		end, { noremap = true, desc = "push" })
		vim.keymap.set("n", "<C-g>pf", function()
			vim.cmd.Git("push --force")
		end, { noremap = true, desc = "force push" })
		vim.keymap.set("n", "<C-g>pu", function()
			local handle = io.popen("git branch --show-current")
			local current_branch
			if handle then
				current_branch = handle:read("*a")
				handle:close()
			else
				print(
					"Error: 'git branch --show-current' failed. Please ensure 'git' is installed and included in your PATH environment variable."
				)
			end

			if current_branch then
				-- Removes the newline character at the end of 'git branch --show-current'.
				current_branch = current_branch:gsub("\n", "")

				local confirm_push
				vim.ui.input(
					{ prompt = "Are you sure you want to push to the branch, " .. current_branch .. " ? y/n: " },
					function(input)
						confirm_push = input
					end
				)

				if confirm_push:lower() ~= "y|yes" then
					vim.cmd("Git push -u origin " .. current_branch)
				end
			else
				print("Error: no current 'git' branch detected")
			end
		end, { noremap = true, desc = "push branch upstream (prompt confirmation)" })

		vim.api.nvim_set_keymap(
			"n",
			"<C-g>of",
			"<cmd>GBrowse<cr>",
			{ noremap = true, silent = true, desc = "browse file in browser" }
		)

		vim.api.nvim_set_keymap(
			"n",
			"<C-g>ol",
			"<cmd>.GBrowse<cr>",
			{ noremap = true, silent = true, desc = "browse current line in browser" }
		)

		vim.keymap.set("n", "<C-g>or", function()
			vim.fn.system({ "gh", "browse" })
		end, { noremap = true, silent = true, desc = "browse repo in browser" })
	end,
}
