return {
  'nat-418/boole.nvim',
  opts = {
    mappings = {
      increment = '<C-a>',
      decrement = '<C-x>'
    },
    -- User defined loops
    additions = {
      {'foo', 'bar'},
    },
    allow_caps_additions = {
      {'true', 'false'}
      -- enable → disable
      -- Enable → Disable
      -- ENABLE → DISABLE
    }
  },
}
