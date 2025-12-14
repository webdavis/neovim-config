return {
  "RRethy/vim-illuminate",
  dependencies = {
    "folke/snacks.nvim",
  },
  event = "VeryLazy",
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = {
      providers = {
        "lsp",
        "treesitter",
        "regex",
      },
    },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    require("snacks")
      .toggle({
        name = "Illuminate",
        get = function()
          return not require("illuminate.engine").is_paused()
        end,
        set = function(enabled)
          local m = require("illuminate")
          if enabled then
            m.resume()
          else
            m.pause()
          end
        end,
      })
      :map("<leader>ui")

    local function map(key, dir, buffer)
      vim.keymap.set("n", key, function()
        require("illuminate")["goto_" .. dir .. "_reference"](true)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
    end

    map("<M-n>", "next")
    map("<M-p>", "prev")

    -- Also set it after loading ftplugins.
    -- NOTE: the following is only relevant if you use the [[ and ]] mappings, since a lot of plugins overwrite [[ and ]].
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map("<M-n>", "next", buffer)
        map("<M-p>", "prev", buffer)
      end,
    })
  end,
  keys = {
    { "<M-n>", desc = "Next Reference" },
    { "<M-p>", desc = "Prev Reference" },
  },
}
