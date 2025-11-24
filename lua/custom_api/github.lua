local M = {}

local module_name = "custom_api.github"

local wrap = require("custom_api.helpers").wrap
local run_shell_command = require("custom_api.util").run_shell_command

-- ╭──────────╮
-- │  Helpers │
-- ╰──────────╯
local log_warning = vim.log.levels.WARN

-- ╭──────╮
-- │  API │
-- ╰──────╯
local function account(opts)
  _ = opts or {}

  local exit, username = run_shell_command({ command = "git config --get github.username" })

  if exit ~= 0 then
    exit, username = run_shell_command({ command = "gh api user --jq .login" })
  end

  if exit ~= 0 then
    return nil,
      "Unable to read git *github.username* and not logged into GitHub CLI.\n"
        .. 'Run `git config --global github.username "github_account"` to set it.\n\n'
        .. "Additionally, run `gh auth login` to login to GitHub"
  end

  return username
end

-- ╭─────────────────────╮
-- │  Wrapped Functions  │
-- ╰─────────────────────╯
M.account = wrap(module_name, account, { log_level = log_warning })

return M
