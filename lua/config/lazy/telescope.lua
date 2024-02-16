return {
  'nvim-telescope/telescope.nvim', tag = '0.1.5',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzf-native.nvim',
    'nvim-telescope/telescope-github.nvim',
    'davvid/telescope-git-grep.nvim',
    'barrett-ruth/telescope-http.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    'nvim-telescope/telescope-project.nvim',
    'nvim-lua/popup.nvim',
    'nvim-telescope/telescope-media-files.nvim',
    'jvgrootveld/telescope-zoxide',
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
  config = function()
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('gh')
    require('telescope').load_extension('git_grep')
    require('telescope').load_extension('http')
    require('telescope').load_extension('file_browser')
    require('telescope').load_extension('project')
    require('telescope').load_extension('media_files')
    require('telescope').load_extension('zoxide')

    require('telescope').setup {
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          -- '--trim',
        },
        mappings = {
          i = {
            ['<C-u>'] = false
          },
        },
      },
    }

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>fM', builtin.man_pages, {})
    vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
    vim.keymap.set('n', '<leader>fc', builtin.colorscheme, {})
    vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<leader>f/', builtin.current_buffer_fuzzy_find, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>fs', builtin.grep_string, {})
    vim.keymap.set('n', '<leader>ft', '<cmd>Telescope grep_string search=<cr>', {})
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    vim.keymap.set('n', '<leader>fm', builtin.marks, {})
    vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
    vim.keymap.set('n', '<leader>fr', builtin.command_history, {})

    ---------------------
    -- Extension mappings
    ---------------------
    vim.keymap.set('n', '<leader>fH', ':Telescope http list<CR>', {})
    vim.keymap.set('n', '<leader>fM', ':Telescope media_files<CR>', {})
    vim.keymap.set('n', '<leader>fp', ':Telescope project<CR>', {})
    vim.keymap.set('n', '<leader>fz', require('telescope').extensions.zoxide.list)

    ---------------
    -- git mappings
    ---------------
    vim.keymap.set('n', '<C-g><C-g>',':Telescope git_grep grep<CR>', {})
    vim.keymap.set('n', '<C-g>g',':Telescope git_grep live_grep<CR>', {})
    vim.keymap.set('n', '<C-g><space>', builtin.git_branches, {})
    vim.keymap.set('n', '<C-g>l', builtin.git_commits, {})
    vim.keymap.set('n', '<C-g>L', builtin.git_bcommits, {})
    vim.keymap.set('n', '<C-g>f', builtin.git_files, {})
    vim.keymap.set('n', '<C-g>h',':Telescope gh gist<CR>', {})
    vim.keymap.set('n', '<C-g><C-p>',':Telescope gh pull_request<CR>', {})
    vim.keymap.set('n', '<C-g>i',':Telescope gh issues<CR>', {})
    vim.keymap.set('n', '<C-g>o',':Telescope gh secret<CR>', {})
    vim.keymap.set('n', '<C-g>r',':Telescope gh run<CR>', {})
    vim.keymap.set('n', '<C-g>S', builtin.git_status, {})
    vim.keymap.set('n', '<C-g>n', builtin.git_stash, {})

    ------------------------
    -- file-browser mappings
    ------------------------
    vim.keymap.set('n', '<leader>fe', ':Telescope file_browser<CR>', {})
    -- Open file_browser with the path of the current buffer.
    vim.keymap.set('n', '<leader>fE', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', {})
  end,
}
