return {
  "stevearc/conform.nvim",
  event = { "VeryLazy" },
  cmd = { "ConformInfo" },
  config = function()
    local conform = require("conform")

    local find_config = require("config.custom_api").find_config

    conform.setup({
      formatters_by_ft = {
        c = { "clang_format" },
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { { "prettierd", "prettier" } },
        json = { "jq" },
        just = { "just" },
        markdown = { "mdformat", "lsp" },
        nix = { "nixfmt" },
        swift = { "swiftformat_ext" },
        yaml = { "yamlfmt" },
        zig = { "zigfmt" },
        ["_"] = { "trim_whitespace" },
        ["*"] = { "typos" },
      },
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
        yamlfmt = {
          command = "yamlfmt",
          args = {
            "-formatter",
            "retain_line_breaks_single=true",
            "-formatter",
            "include_document_start=true",
            "-",
          },
        },
        swiftformat_ext = {
          command = "swiftformat",
          args = function()
            return {
              "--config",
              find_config(".swiftformat"),
              "--stdinpath",
              "$FILENAME",
            }
          end,
          range_args = function(ctx)
            return {
              "--config",
              find_config(".swiftformat"),
              "--linerange",
              ctx.range.start[1] .. "," .. ctx.range["end"][1],
            }
          end,
          stdin = true,
          condition = function(ctx)
            return vim.fs.basename(ctx.filename) ~= "README.md"
          end,
        },
      },
      format_on_save = function(bufnr)
        local result
        if not vim.g.disable_autoformat and not vim.b[bufnr].disable_autoformat then
          result = { timeout_ms = 500, lsp_fallback = true }
        end
        return result
      end,
      log_level = vim.log.levels.ERROR,
    })

    -- ConformEnable! will enable formatting just for current buffer.
    vim.api.nvim_create_user_command("ConformEnable", function(args)
      (args.bang and vim.b or vim.g)["disable_autoformat"] = false
    end, { desc = "conform - enable autoformat on save", bang = true })

    -- ConformDisable! will disable formatting just for current buffer.
    vim.api.nvim_create_user_command("ConformDisable", function(args)
      (args.bang and vim.b or vim.g)["disable_autoformat"] = true
    end, { desc = "conform - disable format on save", bang = true })

    local log_levels = vim.log.levels
    vim.api.nvim_create_user_command("ConformToggle", function()
      if vim.g["disable_autoformat"] then
        vim.g["disable_autoformat"] = false
        vim.notify("Enabled format on save (global)", log_levels.INFO)
      else
        vim.g["disable_autoformat"] = true
        vim.notify("Disabled format on save (global)", log_levels.WARN)
      end
    end, { desc = "conform - toggle format on save", bang = false })

    local map = require("config.custom_api").map

    map({ "n", "x" }, "<leader>cf", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end, "conform - format buffer or range (in visual mode)", true)

    map("n", "<M-f>", "ConformToggle", "conform - toggle format on save", false)
    map("n", "<leader>ce", "ConformEnable", "Format on save: Enabled (global)", true)
    map("n", "<leader>cE", "ConformEnable!", "Format on save: Enabled (buffer)", true)
    map("n", "<leader>cd", "ConformDisable", "Format on save: Disabled (global)", true)
    map("n", "<leader>cD", "ConformDisable!", "Format on save: Disabled (buffer)", true)
  end,
}
