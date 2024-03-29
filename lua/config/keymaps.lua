vim.g.mapleader = " "

-- Faster file manipulation.
vim.keymap.set({ "n" }, "<C-s>", "<cmd>write<cr><esc>", { noremap = true, silent = false, desc = "quickly save file" })
vim.keymap.set({ "n" }, "<C-q>", "<cmd>quit<cr>", { noremap = true, silent = true, desc = "quickly quit the file" })
vim.keymap.set({ "n" }, "<leader><C-s>", "<cmd>wa<cr>", { noremap = true, silent = false, desc = "write - all files" })
vim.keymap.set({ "n" }, "<leader>e", "<cmd>new<cr>", { noremap = true, silent = true, desc = "new file" })
vim.keymap.set({ "n" }, "<leader>0a", "<cmd>qa<cr>", { noremap = true, silent = true, desc = "quit all" })
vim.keymap.set({ "n" }, "<leader>0f", "<cmd>qa!<cr>", { noremap = true, silent = true, desc = "force quit all" })

-- https://github.com/pocco81/auto-save.nvim
vim.keymap.set({ "n" }, "<leader>S", "<cmd>ASToggle<cr>", { noremap = true, silent = false, desc = "autosave - activate" })

-- Open Lazy screen.
vim.keymap.set({ "n" }, "<leader>la", "<cmd>Lazy<cr>", { noremap = true, silent = true, desc = "lazy - open lazy dashboard" })
vim.keymap.set({ "n" }, "<leader>lp", "<cmd>Lazy profile<cr>", { noremap = true, silent = true, desc = "lazy - profile plugins" })
vim.keymap.set({ "n" }, "<leader>ll", "<cmd>Lazy log<cr>", { noremap = true, silent = true, desc = "lazy - open plugin logs" })

-- Better line shifting.
vim.keymap.set({ "v" }, "<", "<gv", { desc = "shift left" })
vim.keymap.set({ "v" }, ">", ">gv", { desc = "shift right" })

-- See :help toggleterm.txt
vim.keymap.set(
  { "n", "t", "i", "v" },
  "<C-_>",
  "<cmd>ToggleTerm<cr>",
  { noremap = true, silent = true, desc = "toggleterm - open/close" }
)

-- Copy, Cut, Paste clipboard integration.
vim.keymap.set({ "x" }, "<C-c>", '"+y', { noremap = true, desc = "copy to clipboard" })
vim.keymap.set({ "x" }, "<C-f>", '"+p', { noremap = true, desc = "paste from clipboard" })

-- Better up and down keys when there is line wrapping.
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Resize windows.
vim.keymap.set({ "n" }, "<C-Up>", "<cmd>resize +2<cr>", { noremap = true, desc = "increase window height" })
vim.keymap.set({ "n" }, "<C-Down>", "<cmd>resize -2<cr>", { noremap = true, desc = "decrease window height" })
vim.keymap.set({ "n" }, "<C-Left>", "<cmd>vertical resize -2<cr>", { noremap = true, desc = "decrease window width" })
vim.keymap.set({ "n" }, "<C-Right>", "<cmd>vertical resize +2<cr>", { noremap = true, desc = "increase window width" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set({ "n" }, "n", "'Nn'[v:searchforward]", { noremap = true, expr = true, desc = "next search result" })
vim.keymap.set({ "x" }, "n", "'Nn'[v:searchforward]", { noremap = true, expr = true, desc = "next search result" })
vim.keymap.set({ "o" }, "n", "'Nn'[v:searchforward]", { noremap = true, expr = true, desc = "next search result" })
vim.keymap.set({ "n" }, "N", "'nN'[v:searchforward]", { noremap = true, expr = true, desc = "prev search result" })
vim.keymap.set({ "x" }, "N", "'nN'[v:searchforward]", { noremap = true, expr = true, desc = "prev search result" })
vim.keymap.set({ "o" }, "N", "'nN'[v:searchforward]", { noremap = true, expr = true, desc = "prev search result" })

-- Make the current file executable.
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = false, desc = "make current file executable" })

-- Replace word under cursor text with last yanked text.
vim.keymap.set("n", "<leader>p", [[viw"_dP]], { desc = "replace <cword> with yanked text" })

-- Yank to end of line without line-ending character.
vim.keymap.set("n", "Y", '"+yg_', { desc = "Yank to EOL (without line-ending)" })

-- Toggle quickfix list.
local toggle_qf = function()
  local qf_open = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_open = true
    end
  end
  if qf_open == true then
    vim.cmd("cclose")
    return
  end
  vim.cmd("copen")
  vim.api.nvim_feedkeys([['"]], "im", false)
end

vim.keymap.set("n", "<M-0>", function()
  toggle_qf()
end, { desc = "quickfix - toggle" })
