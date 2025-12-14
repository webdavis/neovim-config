return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({

      -- Install parsers synchronously (only applied to `ensure_installed`).
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
        "cpp",
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
        "just",
        "latex",
        "lua",
        "markdown",
        "markdown_inline",
        "ninja",
        "nix",
        "nu",
        "python",
        "query",
        "regex",
        "ron",
        "rst",
        "rust",
        "swift",
        "terraform",
        "toml",
        "typescript",
        "typst",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "zig",
      },
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,
    })
  end,
}
