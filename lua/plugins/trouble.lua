return {
  'folke/trouble.nvim',
  config = function()
    require('trouble').setup({
      icons = false,
    })

    vim.keymap.set('n', '<leader>tt', function() require('trouble').toggle() end, { noremap = true, silent = true, desc = 'trouble - list buffer diagnostics' })
    vim.keymap.set('n', '<leader>tw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { noremap = true, silent = true, desc = 'trouble - list workspace diagnostics' })
    vim.keymap.set('n', '<leader>tr', '<cmd>Trouble lsp_references<cr>', { noremap = true, silent = true, desc = 'trouble - list LSP references for <cword>' })

    vim.keymap.set('n', '[r', function() require('trouble').next({ skip_groups = true, jump = true }); end, { desc = 'trouble - jump to previous' })
    vim.keymap.set('n', ']r', function() require('trouble').previous({ skip_groups = true, jump = true }); end, { desc = 'trouble - jump to next' })
  end
}
