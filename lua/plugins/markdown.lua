local map = require("config.custom_api").map

return {
  {
    "OXY2DEV/markview.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    lazy = false,
    config = function()
      local markview = require("markview")

      -- Integrate advanced code editor feature.
      require("markview.extras.editor").setup()

      local snacks = require("snacks")

      local markview_global_toggle = snacks.toggle({
        name = "Markview (global)",
        get = function()
          local state = require("markview.state")
          local attached = state.get_attached_buffers()
          if #attached == 0 then
            return state.get_buffer_state(-1, true).enable
          else
            return state.get_buffer_state(attached[1], false).enable
          end
        end,
        set = function(state)
          if state then
            markview.commands.Enable()
          else
            markview.commands.Disable()
          end
        end,
      })
      markview_global_toggle:map("<leader>um")
      markview_global_toggle:map("<leader>me")

      local markview_buffer_toggle = snacks.toggle({
        name = "Markview (buffer)",
        get = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local buf_state = require("markview.state").vars.buffer_states[bufnr]
          return buf_state and buf_state.enable == true
        end,
        set = function(state)
          if state then
            markview.commands.enable()
          else
            markview.commands.disable()
          end
        end,
      })
      markview_buffer_toggle:map("<leader>uM")
      markview_buffer_toggle:map("<leader>mE")

      map({
        mode = "n",
        lhs = "<leader>mx",
        rhs = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- 1-based row
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

          -- 1. Find the start of the task.
          local start_row = row
          while start_row > 1 and lines[start_row - 1]:match("^%s") do
            start_row = start_row - 1
          end

          -- 2. Find the end of the task.
          local end_row = row
          while end_row < #lines and lines[end_row + 1]:match("^%s") do
            end_row = end_row + 1
          end

          local first_line = lines[start_row]

          -- 3. Detect checkbox state on first line of task.
          local unchecked = first_line:match("^%s*%- %[ %]") ~= nil
          local checked = first_line:match("^%s*%- %[[xX]%]") ~= nil

          -- 4. Toggle the checkbox.
          local new_checked
          if unchecked then
            lines[start_row] = first_line:gsub("^(%s*%-+%s*)%[ %]", "%1[x]") -- check
            new_checked = true
          elseif checked then
            lines[start_row] = first_line:gsub("^(%s*%-+%s*)%[[xX]%]", "%1[ ]") -- uncheck
            new_checked = false
          else
            vim.notify("Not a valid Markdown task", vim.log.levels.WARN, { title = "Markview" })
            return
          end

          -- 5. Handle the completion comment on the last line.
          local last_line = lines[end_row]
          local comment_pattern = "%s*<!%-%- completed: %d%d%d%d%-%d%d%-%d%d %-%->"
          local comment = " <!-- completed: " .. os.date("%Y-%m-%d") .. " -->"

          if new_checked then
            if not last_line:match(comment_pattern) then
              lines[end_row] = last_line .. comment
            end
          else
            lines[end_row] = last_line:gsub(comment_pattern, "")
          end

          -- 6. Write back updated lines to buffer.
          -- stylua: ignore
          vim.api.nvim_buf_set_lines(
            bufnr,
            start_row - 1,
            end_row,
            false,
            vim.list_slice(lines, start_row, end_row)
          )
        end,
        desc = "Markview: toggle checkbox",
      })
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app/ && yarn install",
    keys = {
      {
        "<leader>ms",
        function()
          local fname = vim.fn.expand("%:t")
          vim.cmd("MarkdownPreview")
          vim.notify("Starting Markdown Preview for " .. fname)
        end,
        desc = "Markdown Preview: Start",
        ft = "markdown",
      },
      {
        "<leader>mS",
        function()
          local fname = vim.fn.expand("%:t")
          vim.cmd("MarkdownPreviewStop")
          vim.notify("Stopping Markdown Preview for " .. fname)
        end,
        desc = "Markdown Preview: Stop",
        ft = "markdown",
      },
      {
        "<leader>uP",
        function()
          local fname = vim.fn.expand("%:t")
          -- Track state in buffer variable
          vim.b.markdown_preview_running = vim.b.markdown_preview_running or false

          if vim.b.markdown_preview_running then
            vim.cmd("MarkdownPreviewStop")
            vim.notify("Stopping Markdown Preview for " .. fname)
            vim.b.markdown_preview_running = false
          else
            vim.cmd("MarkdownPreview")
            vim.notify("Starting Markdown Preview for " .. fname)
            vim.b.markdown_preview_running = true
          end
        end,
        desc = "Markdown Preview: toggle",
        ft = "markdown",
      },
    },
    config = function()
      --
      -- Make the preview server is available to others on my network. (default: 127.0.0.1)
      vim.g.mkdp_open_to_the_world = true
      vim.g.vmt_auto_update_on_save = true
      vim.g.mkdp_echo_preview_url = true
      vim.g.mkdp_open_ip = "dresden.home.webdavis.io"
      vim.g.mkdp_port = "8366"
    end,
  },
  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown" },
    opts = {},
    config = function()
      -- vim.g.vmt_dont_insert_fence = false -- false is the default.
      vim.g.vmt_fence_text = "table-of-contents"
      vim.g.vmt_list_item_char = "-"

      map({
        mode = "n",
        lhs = "<leader>mt",
        rhs = "GenTocGFM",
        desc = "Markdown TOC: generate",
      })

      map({
        mode = "n",
        lhs = "<leader>mu",
        rhs = "UpdateToc",
        desc = "Markdown TOC: update",
      })

      map({
        mode = "n",
        lhs = "<leader>mg",
        rhs = "TocGoto",
        desc = "Markdown TOC: jump to heading under cursor",
      })
    end,
  },
}
