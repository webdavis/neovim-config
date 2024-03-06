return {
  url = 'https://codeberg.org/elfahor/telescope-just.nvim',
  requires = { 'nvim-telescope/telescope.nvim'},
  config = function()
    require('telescope').load_extension('just')
    require('telescope').setup({
      extensions = {
        just = {
          -- I rather suggest dropdown!
          theme = 'ivy',
          -- A good option is to show a popup window.
          -- You can do that with tmux or toggleterm.
          action = function(command)
            vim.fn.system(command)
            print("Executed", command)
          end
        }
      }
    })

    vim.keymap.set('n', '<leader>fj', '<cmd>Telescope just<cr>', { remap = false, silent = true, desc = 'search - justfile commands' })
  end
}
