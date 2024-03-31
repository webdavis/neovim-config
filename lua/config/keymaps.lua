--------------------
-- Core Key Mappings
--------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = require("config.custom_api").map

-- Faster file manipulation.
map("n", "<C-s>", "write", "quickly save file", true)
map("n", "<C-q>", "quit", "quickly quit the file")
map("n", "<leader><C-s>", "wall", "write - all files")
map("n", "<leader>e", "new", "new file")
map("n", "<leader>0a", "qa", "quit all")
map("n", "<leader>0f", "qa!", "force quit all")

-- https://github.com/pocco81/auto-save.nvim
map("n", "<leader>S", "ASToggle", "autosave - activate")

-- Open Lazy screen.
map("n", "<leader>la", "Lazy", "lazy - open lazy dashboard")
map("n", "<leader>lp", "Lazy profile", "lazy - profile plugins")
map("n", "<leader>ll", "Lazy log", "lazy - open plugin logs")

-- Better line shifting.
map("v", "<", "<gv", "shift left")
map("v", ">", ">gv", "shift right")

-- See :help toggleterm.txt
map({ "n", "t", "i", "v" }, "<C-_>", "ToggleTerm", "toggleterm - open/close")

-- Copy, Cut, Paste clipboard integration.
map("x", "<C-c>", '"+y', "copy to clipboard")
map("x", "<C-f>", '"+p', "paste from clipboard")

-- Better up and down keys when there is line wrapping.
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Resize windows.
map("n", "<C-Up>", "resize +2", "increase window height")
map("n", "<C-Down>", "resize -2", "decrease window height")
map("n", "<C-Left>", "vertical resize -2", "decrease window width")
map("n", "<C-Right>", "vertical resize +2", "increase window width")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward]", "next search result")
map("x", "n", "'Nn'[v:searchforward]", "next search result")
map("o", "n", "'Nn'[v:searchforward]", "next search result")
map("n", "N", "'nN'[v:searchforward]", "prev search result")
map("x", "N", "'nN'[v:searchforward]", "prev search result")
map("o", "N", "'nN'[v:searchforward]", "prev search result")

-- Make the current file executable.
map("n", "<leader>X", "!chmod +x %", "make current file executable", true)

-- Replace word under cursor text with last yanked text.
map("n", "<leader>p", [[viw"_dP]], "replace <cword> with yanked text")

-- Yank to end of line without line-ending character.
map("n", "Y", '"+yg_', "Yank to EOL (without line-ending)")

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

map("n", "<M-0>", function()
  toggle_qf()
end, "quickfix - toggle")
