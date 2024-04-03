---------------
-- Core options
---------------

-- Disable netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local textwidth = 95
vim.opt.textwidth = textwidth
vim.opt.colorcolumn = tostring(textwidth)

vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.signcolumn = "yes"
vim.opt.exrc = true -- Turn on directory-specific Neovim settings.
vim.opt.incsearch = true
vim.opt.backspace = "indent,eol,start"
vim.opt.wrap = false
vim.opt.whichwrap = "b,s,<,>,[,]"
vim.opt.scrolloff = 1 -- Scroll offset.
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.selection = "inclusive"
vim.opt.fillchars:append("vert:│,fold:—")
vim.opt.showbreak = "↪ "
vim.opt.listchars = [[tab:>\ ,trail:-,extends:→,precedes:<]]
vim.opt.diffopt:append("vertical")
vim.opt.ignorecase = true -- Ignore case in search patterns.
vim.opt.smartcase = true -- Override ignorecase if search pattern contains uppers.
vim.opt.expandtab = true -- Use spaces instead of tabs.
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.smarttab = true
vim.opt.shiftround = true
vim.opt.showmatch = true
vim.opt.matchtime = 3
vim.opt.timeoutlen = 3000 -- Time in milliseconds to wait for a keymap to complete.
vim.opt.ttimeoutlen = 1
vim.opt.modelines = 3 -- Set the number of modelines that are checked for set commands.
vim.opt.updatetime = 200 -- Decrease update time for the following autocommands: CursorHold, CursorHoldI.
vim.opt.cmdheight = 2 -- Make the commandline bigger.
vim.opt.shortmess:remove("f") -- shortmess: This option helps to avoid all the hit-enter prompts caused by file messages,
vim.opt.mouse = "a" -- Turn on the mouse.

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

local backupdir = vim.fn.stdpath("data") .. "/backup"
vim.fn.mkdir(backupdir, "p")
vim.opt.backupdir = backupdir
vim.opt.backup = true

local swapfile_directory = vim.fn.stdpath("data") .. "/swap"
vim.fn.mkdir(swapfile_directory, "p")
vim.opt.directory:prepend(swapfile_directory)
vim.opt.swapfile = true

local undodir = vim.fn.stdpath("data") .. "/undo"
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir
vim.opt.undofile = true

-----------------
-- Theme/graphics
-----------------
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.api.nvim_command("syntax enable")
vim.opt.termguicolors = true -- Enable 24-bit colour.

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
end
