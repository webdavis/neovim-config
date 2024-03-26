return {
  name = "run script",
  builder = function()
    local file = vim.fn.expand("%:p")
    local cmd
    if vim.bo.filetype == "lua" then
      cmd = { "lua", file }
    end
    if vim.bo.filetype == "go" then
      cmd = { "go", "run", file }
    end
    if vim.bo.filetype == "python" then
      cmd = { "python3", file }
    end
    if vim.bo.filetype == "sh" then
      cmd = { "bash", file }
    end
    if vim.bo.filetype == "swift" then
      cmd = "set -eo pipefail; swift build"
    end
    return {
      cmd = cmd,
      components = {
        { "on_output_quickfix", open = false, set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "lua", "sh", "python", "go", "swift" },
  },
}
