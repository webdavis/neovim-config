return {
  "tpope/vim-fugitive",
  dependencies = { "tpope/vim-rhubarb", },
  config = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
    vim.keymap.set("n", "<leader>gc", ":Git commit %<CR>", {noremap = true})

    vim.keymap.set('n', '<leader>gu', function()
      local handle = io.popen("git branch --show-current")
      local current_branch = handle:read("*a")
      handle:close()
      current_branch = current_branch:gsub("\n", "") -- Remove newline character
      vim.cmd("Git push -u origin " .. current_branch)
    end, {buffer = bufnr, remap = false })

    vim.api.nvim_create_user_command('Browse', function (opts) vim.fn.system { 'open', opts.fargs[1] } end, { nargs = 1 })
    vim.api.nvim_set_keymap('n', '<C-g><space>', '<cmd>GBrowse<cr>', { noremap = true, silent = true, desc = 'Open GitHub repo in the browser' })
  end,
}
