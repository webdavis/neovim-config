return {
  "tpope/vim-fugitive",
  dependencies = { "tpope/vim-rhubarb", },
  config = function()
    vim.keymap.set("n", "<C-g>s", vim.cmd.Git)
    vim.keymap.set("n", "<C-g>a", "<cmd>Gwrite<cr>", {noremap = true})
    vim.keymap.set("n", "<C-g>cc", ":Git commit<CR>", {noremap = true})
    vim.keymap.set("n", "<C-g>cv", ":Git commit --verbose<CR>", {noremap = true})
    vim.keymap.set("n", "<C-g>ca", ":Git commit --amend<CR>", {noremap = true})
    vim.keymap.set("n", "<C-g>cn", ":Git commit --amend --no-edit<CR>", {noremap = true})
    vim.keymap.set("n", "<C-g>cf", ":Git commit %<CR>", {noremap = true})

    local bufnr = vim.api.nvim_get_current_buf()
    local opts = { buffer = bufnr, noremap = true }

    vim.keymap.set('n', '<C-g>pp', function() vim.cmd.Git('push') end, opts)
    vim.keymap.set('n', '<C-g>pr', function() vim.cmd.Git({'pull', '--rebase'}) end, opts)

    vim.keymap.set('n', '<C-g>pu', function()
      local handle = io.popen("git branch --show-current")
      local current_branch
      if handle then
        current_branch = handle:read("*a")
        handle:close()
      else
        print("Error: 'git branch --show-current' failed. Please ensure 'git' is installed and included in your PATH environment variable.")
      end

      if current_branch then
        -- Removes the newline character at the end of 'git branch --show-current'.
        current_branch = current_branch:gsub("\n", "")

        local confirm_push
        vim.ui.input({ prompt = 'Are you sure you want to push to the branch, '.. current_branch .. ' ? y/n: ' }, function(input)
          confirm_push = input
        end)

        if confirm_push:lower() ~= 'y|yes' then
          vim.cmd("Git push -u origin " .. current_branch)
        end
      else
        print("Error: no current 'git' branch detected")
      end
    end, opts)

    vim.api.nvim_create_user_command('Browse', function (opts) vim.fn.system { 'open', opts.fargs[1] } end, { nargs = 1 })
    vim.api.nvim_set_keymap('n', '<C-g>br', '<cmd>GBrowse<cr>', { noremap = true, silent = true, desc = 'Opens the file on GitHub in the browser' })
    vim.api.nvim_set_keymap('n', '<C-g>bl', '<cmd>.GBrowse<cr>', { noremap = true, silent = true, desc = 'Opens the file, at the current line, on GitHub in the browser' })
    vim.keymap.set('n', '<C-g>br', function()
      vim.fn.system({ 'gh', 'browse' })
    end, { noremap = true, silent = false, desc = 'Open GitHub repo in the browser' })
  end,
}
