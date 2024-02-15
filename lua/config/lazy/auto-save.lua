return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- Optional lazy loading on command.
  event = { "InsertLeave", "TextChanged" }, -- Optional lazy loading on trigger events.
  opts = {
    enabled = false, -- Start auto-save when the plugin is loaded (i.e. when your package manager loads it)
    execution_message = {
      enabled = true,
      message = function() -- Message to print on save.
        return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
      end,
      dim = 0.18, -- dim the color of `message`.
      cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
    },
    trigger_events = { -- See :h events
      immediate_save = { "BufLeave", "FocusLost" }, -- Vim events that trigger an immediate save.
      defer_save = { "InsertLeave", "TextChanged" }, -- Vim events that trigger a deferred save (saves after `debounce_delay`).
      cancel_defered_save = { "InsertEnter" }, -- Vim events that cancel a pending deferred save.
    },
    condition = nil, -- If set to `nil` then no specific condition is applied.
    write_all_buffers = false, -- Write all buffers when the current one meets `condition`.
    noautocmd = false, -- Do not execute autocmds when saving.
    debounce_delay = 1000, -- Delay after which a pending save is executed.
    debug = false, -- Log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable.
  },
}
