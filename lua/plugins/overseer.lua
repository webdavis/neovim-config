return {
  "stevearc/overseer.nvim",
  opts = {},
  config = function()
    local overseer = require("overseer")
    overseer.setup({
      -- Default task strategy
      strategy = "terminal",
      open_on_start = true,
      -- Template modules to load
      templates = { "builtin", "user.run_script" },
      -- When true, tries to detect a green color from your colorscheme to use for success highlight
      auto_detect_success_color = true,
      -- Patch nvim-dap to support preLaunchTask and postDebugTask
      dap = true,
      -- Configure the task list
      task_list = {
        -- Default detail level for tasks. Can be 1-3.
        default_detail = 1,
        -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_width and max_width can be a single value or a list of mixed integer/float types.
        -- max_width = {100, 0.2} means "the lesser of 100 columns or 20% of total"
        max_width = { 100, 0.2 },
        -- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
        min_width = { 40, 0.1 },
        -- optionally define an integer/float for the exact width of the task list
        width = nil,
        max_height = { 20, 0.1 },
        min_height = 8,
        height = nil,
        -- String that separates tasks
        separator = "────────────────────────────────────────",
        -- Default direction. Can be "left", "right", or "bottom"
        direction = "left",
        -- Set keymap to false to remove default behavior
        -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
        bindings = {
          ["?"] = "ShowHelp",
          ["g?"] = "ShowHelp",
          ["<CR>"] = "RunAction",
          ["<C-e>"] = "Edit",
          ["o"] = "Open",
          ["<C-v>"] = "OpenVsplit",
          ["<C-s>"] = "OpenSplit",
          ["<C-f>"] = "OpenFloat",
          ["<C-q>"] = false,
          ["<C-o>"] = "OpenQuickFix",
          ["p"] = "TogglePreview",
          ["<C-l>"] = false,
          ["<C-h>"] = false,
          ["<M-l>"] = "IncreaseDetail",
          ["<M-h>"] = "DecreaseDetail",
          ["L"] = "IncreaseAllDetail",
          ["H"] = "DecreaseAllDetail",
          ["["] = "DecreaseWidth",
          ["]"] = "IncreaseWidth",
          ["{"] = "PrevTask",
          ["}"] = "NextTask",
          ["<C-k>"] = false,
          ["<C-j>"] = false,
          ["<M-k>"] = "ScrollOutputUp",
          ["<M-j>"] = "ScrollOutputDown",
          ["q"] = "Close",
        },
      },
      -- See :help overseer-actions
      actions = {},
      -- Configure the floating window used for task templates that require input
      -- and the floating window used for editing tasks
      form = {
        border = "rounded",
        zindex = 40,
        -- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_X and max_X can be a single value or a list of mixed integer/float types.
        min_width = 80,
        max_width = 0.9,
        width = nil,
        min_height = 10,
        max_height = 0.9,
        height = nil,
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 10,
        },
      },
      task_launcher = {
        -- Set keymap to false to remove default behavior
        -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
        bindings = {
          i = {
            ["<C-s>"] = "Submit",
            ["<C-c>"] = "Cancel",
          },
          n = {
            ["<CR>"] = "Submit",
            ["<C-s>"] = "Submit",
            ["q"] = "Cancel",
            ["?"] = "ShowHelp",
          },
        },
      },
      task_editor = {
        -- Set keymap to false to remove default behavior
        -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
        bindings = {
          i = {
            ["<CR>"] = "NextOrSubmit",
            ["<C-s>"] = "Submit",
            ["<Tab>"] = "Next",
            ["<S-Tab>"] = "Prev",
            ["<C-c>"] = "Cancel",
          },
          n = {
            ["<CR>"] = "NextOrSubmit",
            ["<C-s>"] = "Submit",
            ["<Tab>"] = "Next",
            ["<S-Tab>"] = "Prev",
            ["q"] = "Cancel",
            ["?"] = "ShowHelp",
          },
        },
      },
      -- Configure the floating window used for confirmation prompts
      confirm = {
        border = "rounded",
        zindex = 40,
        -- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_X and max_X can be a single value or a list of mixed integer/float types.
        min_width = 20,
        max_width = 0.5,
        width = nil,
        min_height = 6,
        max_height = 0.9,
        height = nil,
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 10,
        },
      },
      -- Configuration for task floating windows
      task_win = {
        -- How much space to leave around the floating window
        padding = 2,
        border = "rounded",
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 10,
        },
      },
      -- Configuration for mapping help floating windows
      help_win = {
        border = "rounded",
        win_opts = {},
      },
      -- Aliases for bundles of components. Redefine the builtins, or create your own.
      component_aliases = {
        -- Most tasks are initialized with the default components
        default = {
          { "display_duration", detail_level = 2 },
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_notify",
          "on_complete_dispose",
        },
        -- Tasks from tasks.json use these components
        default_vscode = {
          "default",
          "on_result_diagnostics",
          "on_result_diagnostics_quickfix",
        },
      },
      bundles = {
        -- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks with
        -- these options (passed to list_tasks())
        save_task_opts = {
          bundleable = true,
        },
        -- Autostart tasks when they are loaded from a bundle
        autostart_on_load = true,
      },
      -- A list of components to preload on setup.
      -- Only matters if you want them to show up in the task editor.
      preload_components = {},
      -- Controls when the parameter prompt is shown when running a template
      --   always    Show when template has any params
      --   missing   Show when template has any params not explicitly passed in
      --   allow     Only show when a required param is missing
      --   avoid     Only show when a required param with no default value is missing
      --   never     Never show prompt (error if required param missing)
      default_template_prompt = "allow",
      -- For template providers, how long to wait (in ms) before timing out.
      -- Set to 0 to disable timeouts.
      template_timeout = 3000,
      -- Cache template provider results if the provider takes longer than this to run.
      -- Time is in ms. Set to 0 to disable caching.
      template_cache_threshold = 100,
      -- Configure where the logs go and what level to use
      -- Types are "echo", "notify", and "file"
      log = {
        {
          type = "echo",
          level = vim.log.levels.WARN,
        },
        {
          type = "file",
          filename = "overseer.log",
          level = vim.log.levels.WARN,
        },
      },
    })

    vim.api.nvim_create_user_command("OverseerRestartLast", function()
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify("No tasks found", vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], "restart")
      end
    end, {})

    vim.api.nvim_create_user_command("OverseerWatchRun", function()
      overseer.run_template({ name = "run script" }, function(task)
        if task then
          task:add_component({ "restart_on_save", paths = { vim.fn.expand("%:p") } })
          local main_win = vim.api.nvim_get_current_win()
          overseer.run_action(task, "open vsplit")
          vim.api.nvim_set_current_win(main_win)
        else
          vim.notify("WatchRun not supported for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
        end
      end)
    end, {})

    local toggle_runner = function(cmd)
      if vim.bo.buftype == "terminal" then
        vim.cmd("close")
      else
        vim.cmd(cmd)
      end
    end

    vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<cr>", { remap = false, silent = true, desc = "overseer - run" })
    vim.keymap.set("n", "<leader>ob", "<cmd>OverseerBuild<cr>", { remap = false, silent = true, desc = "overseer - build" })
    vim.keymap.set("n", "<M-o>", "<cmd>OverseerToggle<cr>", { remap = false, silent = true, desc = "overseer - toggle" })
    vim.keymap.set(
      "n",
      "<leader>ol",
      "<cmd>OverseerRestartLast<cr>",
      { remap = false, silent = true, desc = "overseer - restart last task" }
    )
    vim.keymap.set(
      "n",
      "<leader>ow",
      "<cmd>OverseerQuickAction watch<cr>",
      { remap = false, silent = true, desc = "overseer - watch" }
    )

    vim.keymap.set("n", "<leader>oe", function()
      vim.cmd("OverseerRun")
      vim.cmd("OverseerOpen!")
    end, { remap = false, silent = true, desc = "overseer - run and open list" })

    vim.keymap.set("n", "<M-'>", function()
      toggle_runner("OverseerQuickAction open vsplit")
    end, { desc = "overseer - open task in vsplit" })
    vim.keymap.set("n", "<M-;>", function()
      toggle_runner("OverseerQuickAction open hsplit")
    end, { desc = "overseer - open task in hsplit" })
    vim.keymap.set("n", "<M-9>", function()
      toggle_runner("OverseerQuickAction open float")
    end, { desc = "overseer - open task in floating window" })
    vim.keymap.set("n", "<M-r>", function()
      toggle_runner("OverseerWatchRun")
    end, { desc = "overseer - watch run" })
  end,
}
