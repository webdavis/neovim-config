-- Disable netrw.
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.signcolumn = "yes"

-- Turn on directory-specific Neovim settings.
vim.opt.exrc = true

-- Display the colorcolumn at 1 greater than the buffers textwidth. FIXME
local textwidth = 95
vim.opt.textwidth = textwidth
vim.opt.colorcolumn = tostring(textwidth)

-- Shows where the pattern matches, as it has been typed so far.
vim.opt.incsearch = true

-- Enable backspacing over everything in insert mode.
vim.opt.backspace = "indent,eol,start"

-- Do not wrap lines by default.
vim.opt.wrap = false

-- Allow specified keys that move the cursor left/right to move to the previous/next line.
vim.opt.whichwrap = "b,s,<,>,[,]"

-- See :help fo-table
local custom_settings_fo = vim.api.nvim_create_augroup("custom_settings_fo", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = custom_settings_fo,
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:append("t")
    vim.opt.formatoptions:append("n")
    vim.opt.formatoptions:append("j")
    vim.opt.formatoptions:remove("o")
  end,
})

-- Specify the offset from the window border when scrolling.
vim.opt.scrolloff = 1

-- Window split behavior.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- "inclusive" means that the last character of the selection is included in an operation.
-- Include the last character of Visual/Select mode selections. It is only used in Visual and
-- Select mode.
vim.opt.selection = "inclusive"

-- Set the characters used to separate windows and to indicate folds.
vim.opt.fillchars:append("vert:│,fold:—")

-- Display ↪ at the beginning of a line when wrap is set, and → at the eol when nowrap is set.
vim.opt.showbreak = "↪ "
vim.opt.listchars = [[tab:>\ ,trail:-,extends:→,precedes:<]]

-- Start diff mode with vertical splits.
vim.opt.diffopt:append("vertical")

-- Override ignorecase option if search pat contains uppercase letters.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- In Insert mode: use the appropriate number of spaces to insert a <Tab>.
vim.opt.expandtab = true

-- Indent wrapped lines the same amount as the beginning of the line.
vim.opt.breakindent = true

-- Wrap long lines at a character in 'breakat', rather than the last character that fits on the screen.
vim.opt.linebreak = true

-- At the front of a line, Tab/Backspace will insert/delete blanks according to shiftwidth, but
-- tabstop and softtabstop will be used elsewhere.
vim.opt.smarttab = true

-- Round indent to multiple of shiftwidth.
vim.opt.shiftround = true

-- Show matching enclosure for 3 seconds: [],(),{},"",'',<>.
vim.opt.showmatch = true
vim.opt.matchtime = 3

-- Sets the mapped key timeout to 3 seconds, and the key code timeout to essentially 0.
vim.opt.timeoutlen = 3000
vim.opt.ttimeoutlen = 1

vim.opt.backup = true

-- Set the backup file location, creating the location if it doesn't exist.
local backupdir = vim.fn.stdpath("data") .. "/backup"
vim.opt.backupdir = backupdir
vim.fn.mkdir(backupdir, "p")

-- Set the swap file location.
vim.fn.mkdir(vim.fn.stdpath("data") .. "/swap", "p")

-- Set the undo file location.
local undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undodir = undodir
vim.fn.mkdir(undodir, "p")
vim.opt.undofile = true

-- Set the number of modelines that are checked for set commands.
vim.opt.modelines = 3

-- Decrease update time for the following autocommands: CursorHold, CursorHoldI.
vim.opt.updatetime = 200

-- Make the commandline bigger.
vim.opt.cmdheight = 2

-- shortmess: This option helps to avoid all the hit-enter prompts caused by file messages,
-- for example with CTRL-G, and to avoid some other messages. It is a list of flags:
--   * f: use "(3 of 5)" instead of "(file 3 of 5)".
vim.opt.shortmess:remove("f")

-- Turn on the mouse.
vim.opt.mouse = "a"

--------------------
-- Colorscheme stuff
--------------------
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.api.nvim_command("syntax enable")
vim.opt.termguicolors = true -- Enable 24-bit colour.

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
end
