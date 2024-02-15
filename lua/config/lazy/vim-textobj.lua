return {
  {'kana/vim-textobj-user'},
  {'kana/vim-textobj-line', dependencies = {'kana/vim-textobj-user'}},
  {'kana/vim-textobj-entire', dependencies = {'kana/vim-textobj-user'}},
  {'kana/vim-textobj-datetime', dependencies = {'kana/vim-textobj-user'}},
  {'vimtaku/vim-textobj-keyvalue', dependencies = {'kana/vim-textobj-user'}},
  {'thinca/vim-textobj-between', dependencies = {'kana/vim-textobj-user'}},
  {'sgur/vim-textobj-parameter', dependencies = {'kana/vim-textobj-user'}},
  {'mattn/vim-textobj-url', dependencies = {'kana/vim-textobj-user'}},
  {
    'glts/vim-textobj-comment', dependencies = {'kana/vim-textobj-user'},
    config = function()
      vim.api.nvim_exec([[
          call textobj#user#plugin('comment', {
          \  '-': {
          \    'select-a-function': 'textobj#comment#select_a',
          \    'select-a': 'ag',
          \    'select-i-function': 'textobj#comment#select_i',
          \    'select-i': 'ig',
          \  },
          \  'big': {
          \    'select-a-function': 'textobj#comment#select_big_a',
          \    'select-a': 'aG',
          \   }
          \ })
      ]], true)
    end
  },
}
