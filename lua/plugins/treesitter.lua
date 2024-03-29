return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      -- Install parsers synchronously (only applied to `ensure_installed`).
      sync_install = true,
      modules = {},
      -- List of parsers to ignore installing (or "all").
      ignore_install = {},

      -- Enable syntax highlighting.
      highlight = {
        enable = true,
      },
      indent = { enable = true },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },

      ensure_installed = {
        "bash",
        "c",
        "clojure",
        "css",
        "diff",
        "dockerfile",
        "eex",
        "elixir",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "gpg",
        "graphql",
        "haskell",
        "hcl",
        "heex",
        "html",
        "http",
        "ini",
        "javascript",
        "jq",
        "json",
        "latex",
        "lua",
        "markdown",
        "markdown_inline",
        "ninja",
        "nix",
        "python",
        "query",
        "regex",
        "rst",
        "rust",
        "swift",
        "terraform",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "zig",
      },
      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,
    })
  end,
}
