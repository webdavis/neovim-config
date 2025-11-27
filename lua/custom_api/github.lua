local M = {}

local module_name = "custom_api.github"

local helpers = require("custom_api.helpers")
local util = require("custom_api.util")

-- ╭──────────╮
-- │  Helpers │
-- ╰──────────╯
local log_warning = vim.log.levels.WARN

-- ╭──────╮
-- │  API │
-- ╰──────╯
local function account(opts)
  _ = opts or {}

  local exit, username = util.run_shell_command({ cmd = "git config --get github.username" })

  if exit ~= 0 then
    exit, username = util.run_shell_command({ cmd = "gh api user --jq .login" })
  end

  if exit ~= 0 then
    return nil,
      "Unable to read git *github.username* and not logged into GitHub CLI.\n"
        .. 'Run `git config --global github.username "github_account"` to set it.\n\n'
        .. "Additionally, run `gh auth login` to login to GitHub"
  end

  return username
end

local function repo(opts)
  opts = opts or {}
  local name = opts.name or true
  local owner = opts.owner or false

  local json_field, jq_filter
  if name and owner then
    json_field = "nameWithOwner"
    jq_filter = ".nameWithOwner"
  elseif name then
    json_field = "name"
    jq_filter = ".name"
  elseif owner then
    json_field = "owner"
    jq_filter = ".owner.login"
  end

  local exit, result = util.run_shell_command({
    cmd = string.format("gh repo view --json %s --jq '%s'", json_field, jq_filter),
  })

  if exit ~= 0 or not result or result == "" then
    return nil,
      string.format(
        "Failed to get GitHub repository info for '%s'.\n"
          .. "Make sure you're logged in with `gh auth login` and the repo exists.",
        json_field
      )
  end

  return result
end

-- ╭─────────────────────╮
-- │  Wrapped Functions  │
-- ╰─────────────────────╯
M.account = helpers.wrap(module_name, account, { log_level = log_warning })
M.repo = helpers.wrap(module_name, repo, { log_level = log_warning })

return M
