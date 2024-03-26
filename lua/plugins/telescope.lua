return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
    "nvim-telescope/telescope-github.nvim",
    "davvid/telescope-git-grep.nvim",
    "barrett-ruth/telescope-http.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-project.nvim",
    "nvim-lua/popup.nvim",
    "nvim-telescope/telescope-media-files.nvim",
    "jvgrootveld/telescope-zoxide",
    "ahmedkhalf/project.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
  config = function()
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("gh")
    require("telescope").load_extension("git_grep")
    require("telescope").load_extension("http")
    require("telescope").load_extension("file_browser")
    require("telescope").load_extension("project")
    require("telescope").load_extension("media_files")
    require("telescope").load_extension("zoxide")

    require("telescope").setup({
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          -- '--trim',
        },
        mappings = {
          i = {
            ["<C-u>"] = false,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    })

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>fM", builtin.man_pages, { desc = "find - man pages" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "find - buffers" })
    vim.keymap.set("n", "<leader>fC", builtin.colorscheme, { desc = "find - colorschemes" })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "find - diagnostics" })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find - files" })
    vim.keymap.set("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "find - text in current buffer" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "find - text in files (add matches)" })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "find - word under cursor" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "find - help files" })
    vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "find - marks" })
    vim.keymap.set("n", "<leader>fn", "<cmd>Telescope notify<cr>", { desc = "find - notifications" })
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "find - recent files" })
    vim.keymap.set("n", "<leader>fr", builtin.command_history, { desc = "find - vim command history" })
    vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "find- - show quickfix list" })

    ---------------------
    -- Extension mappings
    ---------------------
    vim.keymap.set("n", "<leader>fy", ":Telescope http list<CR>", { desc = "find - http codes" })
    vim.keymap.set("n", "<leader>fp", ":Telescope project<cr>", { desc = "find - projects" })
    vim.keymap.set("n", "<leader>fz", require("telescope").extensions.zoxide.list, { desc = "find - zoxide directories" })

    ------------------------
    -- file-browser mappings
    ------------------------
    vim.keymap.set("n", "<leader>fe", ":Telescope file_browser<CR>", { desc = "find - file browser" })
    vim.keymap.set(
      "n",
      "<leader>fE",
      ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
      { desc = "find - file browser (current buffer path)" }
    )

    ---------------
    -- git mappings
    ---------------
    vim.keymap.set("n", "<c-g><c-g>", ":telescope git_grep grep<cr>", { desc = "git - grep word under cursor" })
    vim.keymap.set("n", "<C-g>g", ":Telescope git_grep live_grep<CR>", { desc = "git - grep all text" })
    vim.keymap.set("n", "<C-g><space>", builtin.git_branches, { desc = "git - search branches" })
    vim.keymap.set("n", "<C-g>l", builtin.git_commits, { desc = "git - search commits" })
    vim.keymap.set("n", "<C-g>L", builtin.git_bcommits, { desc = "git - search buffer commits" })
    vim.keymap.set("n", "<C-g>f", builtin.git_files, { desc = "git - search files" })
    vim.keymap.set("n", "<C-g>S", builtin.git_status, { desc = "git - search status" })
    vim.keymap.set("n", "<C-g>n", builtin.git_stash, { desc = "git - search stashes" })

    --------------
    -- gh mappings
    --------------
    vim.keymap.set("n", "<C-g>.", ":Telescope gh secret<CR>", { desc = "gh  - search secrets" })
    vim.keymap.set("n", "<C-g><C-p>", ":Telescope gh pull_request<CR>", { desc = "gh  - search pull requests" })
    vim.keymap.set("n", "<C-g>h", ":Telescope gh gist<CR>", { desc = "gh  - search gists" })
    vim.keymap.set("n", "<C-g>i", ":Telescope gh issues<CR>", { desc = "gh  - search issues" })
    vim.keymap.set("n", "<C-g>r", ":Telescope gh run<CR>", { desc = "gh  - search workflow runs" })
  end,
}
