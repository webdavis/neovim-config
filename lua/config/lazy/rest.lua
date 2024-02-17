return {
  "rest-nvim/rest.nvim",
  dependencies = {"nvim-lua/plenary.nvim"},
  config = function()
    require("rest-nvim").setup({
      -- Open request results in a horizontal split.
      result_split_horizontal = false,
      -- Keep the http file buffer above|left when split horizontal|vertical.
      result_split_in_place = false,
      -- Stay in current windows (.http file) or change to results window (default).
      stay_in_current_window_after_split = false,
      -- Skip SSL verification, useful for unknown certificates.
      skip_ssl_verification = false,
      -- Encode URL before making request.
      encode_url = true,
      -- Highlight request on run.
      highlight = {
        enabled = true,
        timeout = 150,
      },
      result = {
        -- Toggle showing URL, HTTP info, headers at top the of result window.
        show_url = true,
        -- Show the generated curl command in case you want to launch the same request via the
        -- terminal (can be verbose).
        show_curl_command = false,
        show_http_info = true,
        show_headers = true,
        -- Table of curl `--write-out` variables or false if disabled for more granular control.
        -- See Statistics Spec.
        show_statistics = false,
        -- Executables or functions for formatting response body [optional]. Set them to false
        -- if you want to disable them.
        formatters = {
          json = "jq",
          html = function(body)
            return vim.fn.system({"tidy", "-i", "-q", "-"}, body)
          end
        },
      },
      -- Jump to request line on run.
      jump_to_request = false,
      env_file = '.env',
      custom_dynamic_variables = {},
      yank_dry_run = true,
      search_back = true,
    })

    vim.keymap.set("n", "<leader>rr", ":lua require('rest-nvim').run()<CR>", { desc = "Run HTTP Request" })
    vim.keymap.set("n", "<leader>rl", ":lua require('rest-nvim').last()<CR>", { desc = "Run Last HTTP Request" })
    vim.keymap.set("n", "<leader>rp", ":lua require('rest-nvim').run(true)<CR>", { desc = "Preview HTTP Request" })
  end
}
