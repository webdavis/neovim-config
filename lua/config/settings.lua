local custom_api = require "config.custom_api"

-- Display the colorcolumn at 1 greater than the buffers textwidth. FIXME
vim.o.colorcolumn = tostring(vim.bo.textwidth + 1)

-- Shows where the pattern matches, as it has been typed so far.
vim.o.incsearch = true

-- Enable backspacing over everything in insert mode.
vim.o.backspace = [[indent,eol,start]]

-- See :help fo-table
vim.cmd([[
  augroup custom_settings_fo
    autocmd!
    autocmd BufEnter * set fo+=t
    autocmd BufEnter * set fo+=n
    autocmd BufEnter * set fo+=j
    autocmd BufEnter * set fo-=o
  augroup END
]])

-- Specify the offset from the window border when scrolling.
vim.o.scrolloff = 1

-- Window split behavior.
vim.o.splitright = true
vim.o.splitbelow = false

-- "inclusive" means that the last character of the selection is included in an operation.
-- Include the last character of Visual/Select mode selections. It is only used in Visual and Select mode.
vim.o.selection = "inclusive"

-- Set the characters used to separate windows and to indicate folds.
vim.cmd "set fillchars+=vert:│,fold:―"

-- Display ↪ at the beginning of a line when wrap is set, and → at the eol when nowrap is set.
vim.o.showbreak = "↪ "
vim.o.listchars = [[tab:>\ ,trail:-,extends:→,precedes:<]]

-- Start diff mode with vertical splits.
vim.cmd "set diffopt+=vertical"

-- Override ignorecase option if search pat contains uppercase letters.
vim.o.ignorecase = true
vim.o.smartcase = true

-- In Insert mode: use the appropriate number of spaces to insert a <Tab>.
vim.o.expandtab = true

-- Do not wrap lines by default.
vim.cmd([[
  augroup custom_settings_nowrap
    autocmd!
    autocmd BufEnter * set nowrap
  augroup END
]])

-- Indent wrapped lines the same amount as the beginning of the line.
vim.o.breakindent = true

-- Wrap long lines at a character in 'breakat', rather than the last character that fits on the screen.
vim.o.linebreak = true

-- At the front of a line, Tab/Backspace will insert/delete blanks according to shiftwidth, but
-- tabstop and softtabstop will be used elsewhere.
vim.o.smarttab = true

-- Round indent to multiple of shiftwidth.
vim.o.shiftround = true

-- Show matching enclosure for 3 seconds: [],(),{},"",'',<>.
vim.o.showmatch = true
vim.o.matchtime = 3

-- Sets the mapped key timeout to 3 seconds, and the key code timeout to essentially 0.
vim.o.timeoutlen = 3000
vim.o.ttimeoutlen = 1

vim.o.backup = true

-- Set the backup file location, creating the location if it doesn't exist.
vim.o.backupdir = vim.fn.stdpath("data") .. "/backup"
vim.fn.mkdir(vim.o.backupdir, "p")

-- Set the swap file location.
vim.fn.mkdir(vim.fn.stdpath("data") .. "/swap", "p")

-- Set the undo file location.
vim.o.undodir = vim.fn.stdpath("data") .. "/undo"
custom_api.set_option("undofile", { o = true, bo = true })
vim.fn.mkdir(vim.o.undodir, "p")

-- Allow specified keys that move the cursor left/right to move to the previous/next line.
vim.o.whichwrap = "b,s,<,>,[,]"

-- Set the number of modelines that are checked for set commands.
vim.o.modelines = 3

-- Decrease update time for the following autocommands: CursorHold, CursorHoldI.
vim.o.updatetime = 200

-- Make the commandline bigger.
vim.o.cmdheight = 2

-- shortmess: This option helps to avoid all the hit-enter prompts caused by file messages,
-- for example with CTRL-G, and to avoid some other messages. It is a list of flags:
--   * f: use "(3 of 5)" instead of "(file 3 of 5)".
vim.cmd('set shortmess-=f')

-- Turn on the mouse.
vim.o.mouse = "a"

-- Disable netrw.
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

----------------------
-- Custom API Settings
----------------------
custom_api.set_option("number", { o = true, wo = true })
custom_api.set_option("relativenumber", { o = true, wo = true })
custom_api.set_option("shiftwidth", { o = 4, bo = 4 })
custom_api.set_option("softtabstop", { o = 4, bo = 4 })
custom_api.set_option("textwidth", { o = 95, bo = 95 })
custom_api.set_option("signcolumn", { o = "yes", wo = "yes" }) -- Always display the signcolumn.

--------------------
-- Colorscheme stuff
--------------------
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.api.nvim_command("syntax enable")
vim.opt.termguicolors = true -- Enable 24-bit colour.

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
end
