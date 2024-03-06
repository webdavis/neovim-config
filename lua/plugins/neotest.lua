return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'marilari88/neotest-vitest',
      'nvim-neotest/neotest-plenary',
    },
    config = function()
      local neotest = require('neotest')
      neotest.setup({
        adapters = {
          require('neotest-vitest'),
          require('neotest-plenary').setup({
            -- this is my standard location for minimal vim rc
            -- in all my projects
            min_init = './scripts/tests/minimal.vim',
          }),
        }
      })

      vim.keymap.set('n', '<leader>tc', function() neotest.run.run() end, { desc = 'neotest - run nearest test' })
      vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand('%')) end, { desc = 'neotest - run all tests in file' })
      vim.keymap.set('n', '<leader>t0', function() neotest.run.run(vim.loop.cwd()) end, { desc = 'neotest - run all tests in workspace' })
      vim.keymap.set('n', '<leader>tl', function() neotest.run.run_last() end, { desc = 'neotest - run most recent test' })
      vim.keymap.set('n', '<leader>th', function() neotest.run.stop() end, { desc = 'neotest - halt tests' })
      vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end, { desc = 'neotest - toggle summary' })
      vim.keymap.set('n', '<leader>tm', function() neotest.output.open({ enter = true, auto_close = true }) end, { desc = 'neotest - show output' })
      vim.keymap.set('n', '<leader>to', function() neotest.output_panel.toggle() end, { desc = 'neotest - toggle output panel' })

      vim.keymap.set('n', ']t', function() neotest.jump.next() end, { desc = 'neotest - jump to next test' })
      vim.keymap.set('n', '[t', function() neotest.jump.next() end, { desc = 'neotest - jump to previous test' })
    end,
  },
}
