local M = {}

-- For an in-depth investigation about what this does, see
-- https://chat.openai.com/share/da304881-b98e-4133-bc6b-5995da37f3ef
M.set_option = function(option, context_dictionary)
  for key, value in pairs(context_dictionary) do
    if key == "o" then
      vim.api.nvim_set_option(option, value)
    end
    if key == "bo" then
      vim.api.nvim_buf_set_option(vim.fn.bufnr(), option, value)
    end
    if key == "wo" then
      vim.api.nvim_win_set_option(0, option, value)
    end
  end
end

local execute_silently = function(rhs, desc, notify)
  if type(rhs) == "function" then
    rhs()
  elseif type(rhs) == "string" then
    vim.cmd(rhs)
  end

  if notify then
    vim.notify(desc, vim.log.levels.INFO)
  end
end

local is_silent_cmd = function(rhs)
  local silent = true
  if type(rhs) == "string" then
    if rhs:match("^:<C%-u>") then
      silent = false
    end
  end
  return silent
end

M.map = function(mode, lhs, rhs, desc, notify)
  local silent = is_silent_cmd(rhs)
  local options = { noremap = true, desc = desc, silent = silent }

  if silent then
    local callback = function()
      execute_silently(rhs, desc, notify)
    end

    vim.keymap.set(mode, lhs, callback, options)
  else
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

local cachedConfig = {}
local searchedForConfig = {}

M.find_config = function(filename)
  if searchedForConfig[filename] then
    return cachedConfig[filename]
  end

  local configs = vim.fn.systemlist({
    "find",
    vim.fn.getcwd(),
    "-maxdepth",
    "2",
    "-iname",
    filename,
    "-not",
    "-path",
    "*/.*/*",
  })
  searchedForConfig[filename] = true

  if vim.v.shell_error ~= 0 then
    return nil
  end

  table.sort(configs, function(a, b)
    return a ~= "" and #a < #b
  end)

  if configs[1] then
    cachedConfig[filename] = string.match(configs[1], "^%s*(.-)%s*$")
  end

  return cachedConfig[filename]
end

return M
