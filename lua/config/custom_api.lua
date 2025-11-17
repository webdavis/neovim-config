-- ╭───────────────────╮
-- │   My Custom API   │
-- ╰───────────────────╯

---@class config.custom_api
---My custom Neovim API.
---`map` supports multiple keys, automatic silent handling, and merging user-provided options.
local M = {}

---Determines whether a mapping should be silent based on its right-hand side (rhs).
---Mappings that execute Vim commands (starting with `:`) are considered *not silent*.
---All other mappings (like Lua functions or non-command strings) are silent by default.
---
---Example:
---```lua
---is_command_silent(":echo 'hi'") --> false
---is_command_silent(function() print("hi") end) --> true
---```
---@param rhs string|fun():any The right-hand side of the mapping.
---@return boolean `true` if the mapping should be silent, otherwise `false`.
local is_command_silent = function(rhs)
  -- Returns true if `rhs` is not a Vim command starting with :.
  -- Mappings with such commands should be silent.

  return not (type(rhs) == "string" and rhs:match("^:"))
end

---@class config.custom_api.map
---@field mode string|table Vim mode(s) for the mapping (e.g., "n", "i", { "n", "v" }).
---@field lhs string|table The left-hand side key(s) to map.
---@field rhs string|fun():any The right-hand side action to execute.
---@field desc string|nil Description of the mapping (shown in tools like `which-key`).
---@field sequence boolean|nil If true, treats the mapping as part of a key sequence.
---@field expr boolean|nil If true, evaluates the `rhs` as an expression.
---@field nowait boolean|nil If true, mapping doesn’t wait for additional input.
---@field remap boolean|nil If true, allows recursive mapping.

---Creates one or more key mappings with smart defaults.
---
---`opts` table schema:
---```text
---{
---  mode      : string|table       Required: Vim mode(s) for the mapping, e.g., "n" or { "n", "v" }.
---  lhs       : string|table       Required: Left-hand side key(s) to map.
---  rhs       : string|fun():any   Required: Right-hand side action to execute.
---  desc      : string             Required: Description for which-key or documentation.
---  sequence? : boolean            Optional: If true, treats mapping as part of a key sequence.
---  expr?     : boolean            Optional: Evaluate RHS as an expression.
---  nowait?   : boolean            Optional: Don’t wait for additional input.
---  remap?    : boolean            Optional: Allow recursive mapping.
---}
---```
---
---This function wraps `vim.keymap.set` and:
--- 1. Automatically applies `noremap = true`, by default.
--- 2. Automatically sets `silent` unless the `rhs` runs a Nvim/Vim command.
--- 3. Supports mapping multiple `lhs` keys in a single call.
--- 4. Merges additional options like `expr`, `nowait`, or `remap`.
---
---Example usage:
---```lua
---local map = require("config.custom_api").map
---
----- Normal mode mapping, Vim command
---map({
---  mode = "n",
---  lhs = "<leader>ff",
---  rhs = "Telescope find_files",
---  desc = "Telescope: find files"
---})
---
----- Insert mode, multiple keys mapped to Lua function
---map({
---  mode = "i",
---  lhs = { "jk", "jj" },
---  rhs = function()
---    local escape = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
---    return vim.api.nvim_feedkeys(escape, "n", true)
---  end,
---  desc = "Exit insert mode"
---})
---```
---@param opts config.custom_api.map The options table containing the mapping configuration.
---@return nil
function M.map(opts)
  local mode = opts.mode
  local lhs_list = opts.lhs
  local rhs = opts.rhs
  local sequence = opts.sequence

  local desc = opts.desc

  if type(lhs_list) == "string" then
    lhs_list = { lhs_list }
  end

  -- Start with the defaults.
  local keymap_opts = { noremap = true, desc = desc, silent = is_command_silent(rhs) }

  -- Merge any extra options from opts (e.g., expr, nowait, remap).
  for k, v in pairs(opts) do
    if not (k == "mode" or k == "lhs" or k == "rhs" or k == "sequence") then
      keymap_opts[k] = v
    end
  end

  for _, lhs in ipairs(lhs_list) do
    if sequence or not keymap_opts.silent then
      vim.keymap.set(mode, lhs, rhs, keymap_opts)
    else
      vim.keymap.set(mode, lhs, function(...)
        local res
        if type(rhs) == "function" then
          res = rhs(...)
        elseif type(rhs) == "string" then
          vim.cmd(rhs)
        end

        return res
      end, keymap_opts)
    end
  end
end

local log_info = vim.log.levels.INFO
local log_warning = vim.log.levels.WARN
local log_error = vim.log.levels.ERROR

function M.get_cwd_basename()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

function M.trim(s)
  return (s or ""):gsub("^%s*(.-)%s*$", "%1")
end

-- Lowercase + trim input
function M.sanitize_input(s)
  return M.trim(s):lower()
end

local notify_git_title = { title = "git" }

function M.run_shell_command(command, error_notification)
  local command_string
  if type(command) == "table" then
    command_string = table.concat(command, " ")
  elseif type(command) == "string" then
    command_string = command
  else
    error("run_shell_command: command must be a string or table")
  end

  local output = vim.fn.system(command_string)
  local exit_code = vim.v.shell_error

  local notify_title = { title = "run_shell_command" }

  if exit_code ~= 0 and error_notification then
    if type(error_notification) == "function" then
      error_notification()
    elseif type(error_notification) == "string" then
      vim.notify(error_notification, log_error, notify_title)
    elseif type(error_notification) == "boolean" then
      vim.notify("Error: " .. output, log_error, notify_title)
      error_notification()
    end
  end

  return exit_code, M.trim(output)
end

function M.github_username()
  local exit, username = M.run_shell_command("git config --get github.username")

  if exit ~= 0 then
    exit, username = M.run_shell_command("git config --get github.username")
  end

  if exit ~= 0 then
    vim.notify(
      'Error [`git_user`]: Unable to read git `user.name`. Run *git config --global user.name "Your Name"* to set it.',
      log_error,
      notify_git_title
    )
    return nil
  end

  return username
end

function M.git_initialized(opts)
  opts = opts or {}
  local code, _ = M.run_shell_command("git rev-parse --git-dir")

  if code ~= 0 then
    if not opts.quiet then
      vim.notify(
        "Error [`git_initialized`]: Project hasn't been initialized. Run `git init` to start tracking.",
        log_error,
        notify_git_title
      )
    end
    return false
  end

  return true
end

function M.git_project_name(opts)
  opts = opts or {}

  local code, project = M.run_shell_command("git rev-parse --show-toplevel", function()
    local cwd = M.get_cwd_basename()
    local buffer_path = vim.api.nvim_buf_get_name(0)

    local lines = {
      { "Warning [`git_project`]: Unable to detect Git project root." },
      { "Run `git rev-parse --is-inside-work-tree` to ensure you're in a git repo." },
      { "Current directory: *" .. cwd .. "*" },
      { "Current file: *" .. buffer_path .. "*" },
    }

    local message = table.concat(lines, "\n\n")

    vim.notify(message, log_warning, notify_git_title)
  end)

  if code ~= 0 then
    return nil
  end

  if not opts.full_path or opts.full_path == false then
    project = vim.fn.fnamemodify(project, ":t")
  end

  return project
end

function M.git_branch()
  local _, branch = M.run_shell_command("git branch")

  if branch == "" then
    local cwd = M.get_cwd_basename()
    local message = {
      { "Warning [`git_branch`]: project has been initialized, but unable to detect current `git branch`." },
      { "\nThis could be one of two things:" },
      { "1. You are in a new project that has no commits." },
      { "2. You are in a special *detached HEAD* state" },
      { "Current working directory: `" .. cwd .. "`" },
    }
    vim.notify(table.concat(message, "\n"), log_warning, notify_git_title)
    return nil
  end

  local _, current_branch = M.run_shell_command("git branch --show-current", true)

  return current_branch
end

local function normalize_message(message)
  message = M.trim(message)
  return (message ~= "" and message) or nil
end

function M.git_latest_commit(project)
  local hash_exit, hash = M.run_shell_command("git rev-parse --short HEAD", function()
    local message = {
      "Warning [`git_latest_commit`]: Unable to find latest commit.",
      "This may occur if no commits have been made to *" .. project .. "* yet.",
    }
    vim.notify(table.concat(message, "\n\n"), log_warning, notify_git_title)
  end)

  if hash_exit ~= 0 then
    return nil, nil, nil
  end

  local message_exit, message = M.run_shell_command("git log -1 --pretty=%B", function()
    vim.notify("Warning [`git_laest_commit`]: commit `" .. hash .. "` has no message.", log_warning, notify_git_title)
  end)

  if message_exit ~= 0 then
    return hash, nil, nil
  end

  local summary, body = message:match("([^\n]*)\n?(.*)")

  return hash, normalize_message(summary), normalize_message(body)
end

local function github_url(remote, user, repo_name)
  local code, url = M.run_shell_command("git config --get remote." .. remote .. ".url", function()
    local lines = {
      "Warning [`github_url`]: Couldn't find URL for `" .. remote .. "` remote!",
      "To set the remote URL for '"
        .. remote
        .. "', run: `Git remote set-url "
        .. remote
        .. " git@github.com/"
        .. user
        .. "/"
        .. repo_name
        .. ".git`",
    }
    local message = table.concat(lines, "\n\n")
    vim.notify(message, log_warning, notify_git_title)
  end)

  if code ~= 0 then
    return nil
  end

  return url
end

local function copy_to_system_clipboard(data)
  vim.fn.setreg("+", data)
end

local function convert_remote_protocol(url, from_prefix, to_prefix)
  local user_repo = url:match("^" .. from_prefix .. "(.+)")

  if user_repo then
    return to_prefix .. user_repo
  elseif url:match("^" .. to_prefix) then
    return url
  end

  return nil
end

local function to_https_protocol(url)
  return convert_remote_protocol(url, "git@github.com:", "https://github.com/")
end

local function to_ssh_protocol(url)
  return convert_remote_protocol(url, "https://github.com/", "git@github.com:")
end

function M.copy_URL_to_clipboard(remote, protocol)
  if not M.git_initialized() then
    return
  end

  local url = github_url(remote, M.github_username(), M.git_project_name())

  if not url then
    vim.notify("Warning: Nothing copied to clipboard!", log_warning, notify_git_title)
    return
  end

  local converted_URL
  if protocol == "https" then
    converted_URL = to_https_protocol(url)
  else
    converted_URL = to_ssh_protocol(url)
  end

  local final_URL = converted_URL or url
  copy_to_system_clipboard(final_URL)

  local message = converted_URL
      and "Copied *" .. remote .. "* " .. protocol:upper() .. " URL to clipboard: `" .. final_URL .. "`"
    or table.concat({
      "Warning: Couldn't convert '" .. remote .. "' remote to " .. protocol:upper() .. ": unrecognized protocol!",
      "Copied original URL to clipboard instead: `" .. final_URL .. "`",
    }, "\n")

  vim.notify(message, log_info, notify_git_title)
end

function M.overseer_runner(cmds, operator)
  operator = operator or ";"

  if type(cmds) == "string" then
    cmds = { cmds }
  elseif type(cmds) ~= "table" then
    error("'commands' parameter must be a string or a table")
  end

  for i, c in ipairs(cmds) do
    if type(c) ~= "string" then
      error("Invalid command type at index " .. i .. ": " .. type(c))
    end
  end

  local cmd_str = table.concat(cmds, " " .. operator .. " ")

  -- Create the orchestrator task:
  require("overseer")
    .new_task({
      name = "**Command Orchestrator:** `" .. cmd_str .. "`",
      cmd = cmd_str,
      components = { { "on_complete_notify", statuses = { "SUCCESS" } }, "default" },
    })
    :start()
end

return M
