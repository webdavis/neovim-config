return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    local wk = require('which-key')
    wk.register({
      ['<leader>'] = {
        ['0'] = { name = 'quit' },
        c = { name = 'code action/format(conform)' },
        d = { name = 'diagnostics' },
        f = {
          name = 'find',
          s = { name = 'symbols' },
        },
        g = { name = 'git signs/messenger' },
        h = { name = 'harpoon' },
        j = { name = 'splitjoin' },
        l = { name = 'LSP/lazy' },
        m = { name = 'markdown preview' },
        n = { name = 'neotree/swap next' },
        o = { name = 'overseer' },
        p = { name = 'swap previous' },
        r = { name = 'rest/rename' },
        s = { name = 'save' },
        t = { name = 'test/trouble' },
        u = { name = 'urlview/undotree' },
        v = { name = 'Python venv' },
        w = { name = 'LSP workspace' },
      },
      ['<C-g>'] = {
        b = { name = 'git blame' },
        c = { name = 'git commit' },
        o = { name = 'gh browse' },
        p = { name = 'git push/pull' },
      },
    })
  end
}
