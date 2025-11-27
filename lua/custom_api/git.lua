local M = {}

local module_name = "custom_api.git"

local helpers = require("custom_api.helpers")
local util = require("custom_api.util")

-- ╭──────────╮
-- │  Helpers │
-- ╰──────────╯
local log_warning = vim.log.levels.WARN

local function convert_remote_protocol(remote_url, from_prefix, to_prefix)
  local user_repo = remote_url:match("^" .. from_prefix .. "(.+)")

  if user_repo then
    return to_prefix .. user_repo
  elseif remote_url:match("^" .. to_prefix) then
    return remote_url
  end

  return nil
end

local function to_https_protocol(remote_url)
  return convert_remote_protocol(remote_url, "git@github.com:", "https://github.com/")
end

local function to_ssh_protocol(remote_url)
  return convert_remote_protocol(remote_url, "https://github.com/", "git@github.com:")
end

-- ╭──────╮
-- │  API │
-- ╰──────╯
local function initialized(opts)
  local _ = opts
  local code, _ = util.run_shell_command({ cmd = "git rev-parse --git-dir" })

  if code ~= 0 then
    return nil, "Project hasn't been initialized. Run `git init` to start tracking."
  end

  return true
end

local function top_level(opts)
  local _ = opts

  local code, top_level_dir = util.run_shell_command({ cmd = "git rev-parse --show-toplevel" }, function()
    local cwd = util.get_cwd_basename()
    local buffer_path = vim.api.nvim_buf_get_name(0)

    local lines = {
      { "Unable to detect Git project root." },
      { "Run `git rev-parse --is-inside-work-tree` to ensure you're in a git repo." },
      { "Current directory: *" .. cwd .. "*" },
      { "Current file: *" .. buffer_path .. "*" },
    }

    return nil, table.concat(lines, "\n\n")
  end)

  if code ~= 0 then
    return nil
  end

  if not opts.full_path or opts.full_path == false then
    top_level_dir = vim.fn.fnamemodify(top_level_dir, ":t")
  end

  return top_level_dir
end

local function branch(opts)
  local _ = opts

  local _, branches = util.run_shell_command({ cmd = branch_cmd })

  if branches == "" then
    local cwd = util.get_cwd_basename()
    local message = {
      { "Project has been initialized, but unable to detect current git branch." },
      { "\nThis could mean one of two things:" },
      { "\t1. You are in a new project that has no commits." },
      { "\t2. You are in a special *detached HEAD* state" },
      { "Current working directory: `" .. cwd .. "`" },
    }
    return nil, table.concat(message, "\n")
  end

  local _, current_branch = util.run_shell_command({
    cmd = "git branch --show-current",
    notify_error = true,
  })

  return current_branch
end

local function latest_commit(opts)
  opts = opts or {}
  local repo_name = opts.repo_name

  if not repo_name then
    error("Missing required argument `project`")
  end

  local hash_exit, hash = util.run_shell_command({ cmd = "git rev-parse --short HEAD" })
  if hash_exit ~= 0 then
    return nil,
      nil,
      nil,
      string.format(
        "Unable to find latest commit.\n\nThis may occur if no commits have been made to *%s* yet.",
        repo_name
      )
  end

  local message_exit, message = util.run_shell_command({ cmd = "git log -1 --pretty=%B" })
  if message_exit ~= 0 then
    return hash, nil, nil, string.format("Commit `%s` has no message.", hash)
  end

  local summary, body = message:match("([^\n]*)\n?(.*)")

  return hash, util.normalize(summary), util.normalize(body)
end

local function url(opts)
  opts = opts or {}
  local remote = opts.remote
  local account_name = opts.account_name
  local repo_name = opts.repo_name

  if not remote then
    error("Missing required argument `remote`")
  end
  if not account_name then
    error("Missing required argument `user`")
  end
  if not repo_name then
    error("Missing required argument `repo_name`")
  end

  local cmd = { cmd = string.format("git config --get remote.%s.url", remote) }
  local code, remote_url = util.run_shell_command(cmd)

  if code ~= 0 then
    local lines = {
      ("Couldn't find URL for `%s` remote!"):format(remote),
      ("To set the remote URL for '%s', run: `Git remote set-url %s git@gihub.com/%s/%s.git`"):format(
        remote,
        remote,
        account_name,
        repo_name
      ),
    }
    return nil, table.concat(lines, "\n\n")
  end

  return remote_url
end

local function copy_URL_to_clipboard(opts)
  opts = opts or {}
  local remote = opts.remote
  local protocol = opts.protocol
  local remote_url = opts.url

  if not remote then
    error("Missing required argument `remote`")
  end
  if not protocol then
    error("Missing required argument `protocol`")
  end
  if not remote_url then
    error("Missing required argument `url`")
  end

  local converted_URL
  if protocol == "https" then
    converted_URL = to_https_protocol(remote_url)
  else
    converted_URL = to_ssh_protocol(remote_url)
  end

  local final_URL = converted_URL or remote_url

  util.copy_to_system_clipboard(final_URL)

  if not converted_URL then
    return nil,
      table.concat({
        ("Warning: Couldn't convert '%s' remote to %s: unrecognized protocol!"):format(remote, protocol:upper()),
        ("Copied original URL to clipboard instead: `%s`"):format(final_URL),
      }, "\n")
  end

  return ("Copied *%s* %s URL to clipboard: `%s`"):format(remote, protocol:upper(), final_URL)
end

-- ╭─────────────────────╮
-- │  Wrapped Functions  │
-- ╰─────────────────────╯
M.initialized = helpers.wrap(module_name, initialized, { log_level = log_warning })
M.top_level = helpers.wrap(module_name, top_level, { log_level = log_warning })
M.branch = helpers.wrap(module_name, branch, { log_level = log_warning })
M.latest_commit = helpers.wrap(module_name, latest_commit, { log_level = log_warning })
M.copy_URL_to_clipboard = helpers.wrap(module_name, copy_URL_to_clipboard, { log_level = log_warning })
M.url = helpers.wrap(module_name, url, { log_level = log_warning })

return M
