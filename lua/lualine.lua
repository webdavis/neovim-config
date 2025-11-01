return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local function xcodebuild_device()
      if vim.g.xcodebuild_platform == "macOS" then
        return " macOS"
      end

      if vim.g.xcodebuild_os then
        return " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
      end

      return " " .. vim.g.xcodebuild_device_name
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_buftypes = { "quickfix", "prompt" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
          "diagnostics",
          {
            "searchcount",
            maxcount = 999,
            timeout = 500,
          },
        },
        lualine_c = {
          "%=",
          {
            "filename",
            color = { fg = "#8aadf5", gui = "bold" },
            separator = { left = "x", right = "x" },
            path = 1,
          },
        },
        lualine_x = {
          { "' ' .. vim.g.xcodebuild_last_status", color = { fg = "Gray" } },
          { "'󰙨 ' .. vim.g.xcodebuild_test_plan", color = { fg = "#a6e3a1", bg = "#161622" } },
          { xcodebuild_device, color = { fg = "#f9e2af", bg = "#161622" } },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {
        lualine_c = { "filename" },
      },
      inactive_winbar = {
        lualine_c = { "filename" },
        lualine_x = { "location" },
      },
      extensions = {
        "aerial",
        "fugitive",
        "lazy",
        "man",
        "mason",
        "neo-tree",
        "nvim-dap-ui",
        "oil",
        "overseer",
        "quickfix",
        "symbols-outline",
        "toggleterm",
        "trouble",
      },
    })
  end,
}
