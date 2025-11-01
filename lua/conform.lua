return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  -- lazy = true,
  cmd = "ConformInfo",
  -- keys = {
  --   {
  --     "<leader>cF",
  --     function()
  --       require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
  --     end,
  --     mode = { "n", "v" },
  --     desc = "Format Injected Langs",
  --   },
  -- },
  config = function()
    local conform = require("conform")

    local timeout = vim.bo.filetype == "ansible" and 10000 or 3000

    conform.setup({
      default_format_opts = {
        timeout_ms = timeout,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
      formatters_by_ft = {
        ["*"] = { "codespell" },
        ["_"] = { "trim_whitespace" },
        ansible = { "ansible-lint" },
        c = { "clang_format" },
        fish = { "fish_indent" },
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
        just = { "just" },
        lua = { "stylua" },
        markdown = { "mdformat" },
        nix = { "nixfmt" },
        -- python = { "isort", "black" },
        sh = { "shfmt" },
        swift = { "swiftformat_ext" },
        yaml = { "yamlfmt" },
        zig = { "zigfmt" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args

        -- stylua: ignore start
        shfmt = {
          -- shfmt options: makes shell scripts consistently formatted and easier to read.
          prepend_args = {
            -- Indent with 2 spaces.
            "-i", "2",
            -- Indent `case` blocks inside `switch`.
            "-ci",
          },
        },
        ["ansible-lint"] = {
          args = { "--fix" },
        },
        yamlfmt = {
          command = "yamlfmt",
          args = {
            -- Preserve single line breaks in the YAML.
            "-formatter", "retain_line_breaks_single=true",
            -- Always add the document start marker '---'.
            "-formatter", "include_document_start=true",
            -- Read the YAML content from stdin instead of a file.
            "-",
          },
          -- condition = function()
          --   return vim.bo.filetype ~= "yaml.ansible"
          -- end,
        },
        -- stylua: ignore end
        mdformat = {
          -- Prefer a project-specific mdformat (e.g., installed in .venv via Poetry).
          -- Falls back to the globally installed mdformat if not found.
          command = function()
            local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
            local project_mdformat = git_root .. "/.venv/bin/mdformat"
            if vim.fn.executable(project_mdformat) == 1 then
              return project_mdformat
            end
            return "mdformat" -- Fallback to global.
          end,
          stdin = true,
        },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    })

    local log_info = vim.log.levels.INFO
    local log_warning = vim.log.levels.WARN
    local notify_conform_title = { title = "Conform" }

    vim.api.nvim_create_user_command(
      -- ConformEnable! will enable formatting for current buffer only.
      "ConformEnable",
      function(args)
        local buffer = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        if args.bang then
          vim.b.disable_autoformat = false
          vim.notify("Enabled autoformat-on-save for *" .. buffer .. "*", log_info, notify_conform_title)
        else
          vim.g.disable_autoformat = false
          vim.notify("Enabled autoformat-on-save (Global)", log_info, notify_conform_title)
        end
      end,
      {
        desc = "Conform: enable autoformat-on-save",
        bang = true,
      }
    )

    vim.api.nvim_create_user_command(
      -- ConformDisable! will disable formatting for current buffer only.
      "ConformDisable",
      function(args)
        local buffer = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        if args.bang then
          vim.b.disable_autoformat = true
          vim.notify("Disabled autoformat-on-save for *" .. buffer .. "*", log_warning, notify_conform_title)
        else
          vim.g.disable_autoformat = true
          vim.notify("Disabled autoformat-on-save (Global)", log_warning, notify_conform_title)
        end
      end,
      {
        desc = "Conform: disable autoformat-on-save",
        bang = true,
      }
    )

    vim.api.nvim_create_user_command(
      -- ConformToggle! will toggle formatting for current buffer only.
      "ConformToggle",
      function(args)
        if args.bang then
          if vim.b.disable_autoformat then
            vim.cmd("ConformEnable!")
          else
            vim.cmd("ConformDisable!")
          end
        else
          if vim.g.disable_autoformat then
            vim.cmd("ConformEnable")
          else
            vim.cmd("ConformDisable")
          end
        end
      end,
      {
        desc = "Conform: toggle autoformat-on-save",
        bang = true,
      }
    )

    local map = require("config.custom_api").map

    -- Explanation: supports leaving visual mode after a ranged format.
    map({
      mode = "<leader>cf",
      lhs = "n",
      rhs = function()
        conform.format({ async = true }, function(err)
          if not err then
            local mode = vim.api.nvim_get_mode().mode
            if vim.startswith(string.lower(mode), "v") then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
            end
          end
        end)
      end,
      desc = "Conform: format",
    })

    map({ mode = "n", lhs = "<leader>cc", rhs = "ConformToggle", desc = "Conform: toggle autoformat-on-save (Global)" })
    map({ mode = "n", lhs = "<leader>cC", rhs = "ConformToggle!", desc = "Conform: toggle autoformat-on-save (buffer)" })
    map({ mode = "n", lhs = "<leader>ce", rhs = "ConformEnable", desc = "Conform: enable autoformat-on-save (Global)" })
    map({ mode = "n", lhs = "<leader>cE", rhs = "ConformEnable!", desc = "Conform: enable autoformat-on-save (buffer)" })
    map({
      mode = "n",
      lhs = "<leader>cd",
      rhs = "ConformDisable",
      desc = "Conform: disable autoformat-on-save (Global)",
    })
    map({
      mode = "n",
      lhs = "<leader>cD",
      rhs = "ConformDisable!",
      desc = "Conform: disable autoformat-on-save (buffer)",
    })
  end,
}
