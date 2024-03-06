return {
  'lewis6991/gitsigns.nvim',
  dependencies = {'nvim-lua/plenary.nvim'},
  config = true,
  opts = {
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      map('n', ']h', gs.next_hunk, 'git - jump to next hunk')
      map('n', '[h', gs.prev_hunk, 'git - jump to prev hunk')
      map({ 'n', 'v' }, '<leader>ga', gs.stage_hunk, 'git - stage hunk')
      map({ 'n', 'v' }, '<leader>gr', gs.reset_hunk, 'git - reset hunk (undo changes)')
      map('n', '<leader>gA', gs.stage_buffer, 'git - stage the entire buffer')
      map('n', '<leader>gu', gs.undo_stage_hunk, 'git - unstage hunk under cursor')
      map('n', '<leader>gR', gs.reset_buffer, 'git - reset entire buffer')
      map('n', '<leader>gp', gs.preview_hunk_inline, 'git - show inline preview of hunk')
      map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'git - show blame in a floating window')
      map('n', '<leader>gd', gs.diffthis, 'git - diff against the index')
      map('n', '<leader>gD', function() gs.diffthis('~1') end, "git - diff against last commit")
      map({ 'o', 'x' }, 'ih', gs.select_hunk, 'git - select hunk')
    end,
  },
}
