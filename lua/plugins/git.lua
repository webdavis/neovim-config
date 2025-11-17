local log_info = vim.log.levels.INFO
local log_warning = vim.log.levels.WARN
local log_error = vim.log.levels.ERROR

local map = require("config.custom_api").map

-- ╭─────────────╮
-- │   Helpers   │
-- ╰─────────────╯

local get_cwd_basename = function()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

local function trim(s)
  return (s or ""):gsub("^%s*(.-)%s*$", "%1")
end

-- Lowercase + trim input
local sanitize_input = function(s)
  return trim(s):lower()
end

local notify_fugitive_title = { title = "Fugitive" }
local notify_git_title = { title = "git" }

local function run_shell_command(command, error_notification)
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

  return exit_code, trim(output)
end

local function github_username()
  local exit, username = run_shell_command("git config --get github.username")

  if exit ~= 0 then
    exit, username = run_shell_command("git config --get github.username")
  end

  if exit ~= 0 then
    vim.notify(
      'Error [`git_user`]: Unable to read git `user.name`. Run *git config --global user.name "Your Name"* to set it.',
      log_error,
      notify_fugitive_title
    )
    return nil
  end

  return username
end

local function git_initialized(opts)
  opts = opts or {}
  local code, _ = run_shell_command("git rev-parse --git-dir")

  if code ~= 0 then
    if not opts.quiet then
      vim.notify(
        "Error [`git_initialized`]: Project hasn't been initialized. Run `git init` to start tracking.",
        log_error,
        notify_fugitive_title
      )
    end
    return false
  end

  return true
end

local function git_project_name(opts)
  opts = opts or {}

  local code, project = run_shell_command("git rev-parse --show-toplevel", function()
    local cwd = get_cwd_basename()
    local buffer_path = vim.api.nvim_buf_get_name(0)

    local lines = {
      { "Warning [`git_project`]: Unable to detect Git project root." },
      { "Run `git rev-parse --is-inside-work-tree` to ensure you're in a git repo." },
      { "Current directory: *" .. cwd .. "*" },
      { "Current file: *" .. buffer_path .. "*" },
    }

    local message = table.concat(lines, "\n\n")

    vim.notify(message, log_warning, notify_fugitive_title)
  end)

  if code ~= 0 then
    return nil
  end

  if not opts.full_path or opts.full_path == false then
    project = vim.fn.fnamemodify(project, ":t")
  end

  return project
end

local function git_branch()
  local _, branch = run_shell_command("git branch")

  if branch == "" then
    local cwd = get_cwd_basename()
    local message = {
      { "Warning [`git_branch`]: project has been initialized, but unable to detect current `git branch`." },
      { "\nThis could be one of two things:" },
      { "1. You are in a new project that has no commits." },
      { "2. You are in a special *detached HEAD* state" },
      { "Current working directory: `" .. cwd .. "`" },
    }
    vim.notify(table.concat(message, "\n"), log_warning, notify_fugitive_title)
    return nil
  end

  local _, current_branch = run_shell_command("git branch --show-current", true)

  return current_branch
end

local function normalize_message(message)
  message = trim(message)
  return (message ~= "" and message) or nil
end

local function git_latest_commit(project)
  local hash_exit, hash = run_shell_command("git rev-parse --short HEAD", function()
    local message = {
      "Warning [`git_latest_commit`]: Unable to find latest commit.",
      "This may occur if no commits have been made to *" .. project .. "* yet.",
    }
    vim.notify(table.concat(message, "\n\n"), log_warning, notify_fugitive_title)
  end)

  if hash_exit ~= 0 then
    return nil, nil, nil
  end

  local message_exit, message = run_shell_command("git log -1 --pretty=%B", function()
    vim.notify(
      "Warning [`git_laest_commit`]: commit `" .. hash .. "` has no message.",
      log_warning,
      notify_fugitive_title
    )
  end)

  if message_exit ~= 0 then
    return hash, nil, nil
  end

  local summary, body = message:match("([^\n]*)\n?(.*)")

  return hash, normalize_message(summary), normalize_message(body)
end

local function github_url(remote, user, repo_name)
  local code, url = run_shell_command("git config --get remote." .. remote .. ".url", function()
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
    vim.notify(message, log_warning, notify_fugitive_title)
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

local function copy_URL_to_clipboard(remote, protocol)
  if not git_initialized() then
    return
  end

  local url = github_url(remote, github_username(), git_project_name())

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

local function copy_url_mapping_helper(lhs, remote, protocol)
  local mapping_table = {
    mode = "n",
    lhs = lhs,
    rhs = function()
      if git_initialized() then
        copy_URL_to_clipboard(remote, protocol)
      end
    end,
    desc = "Git (remote): copy " .. protocol:upper() .. " URL (" .. remote .. ")",
  }

  return mapping_table
end

local overseer_runner = function(commands)
  -- If cmds is a single string, convert to table.
  if type(commands) == "string" then
    commands = { commands }
  end

  -- Build orchestrator subtasks:
  local tasks = {}
  for _, c in ipairs(commands) do
    if type(c) == "string" then
      -- Simple shell command.
      table.insert(tasks, c)
    elseif type(c) == "table" then
      -- Assume table has { c, ...options }.
      table.insert(tasks, c)
    end
  end

  -- Create the orchestrator task:
  require("overseer")
    .new_task({
      name = "Command Orchestrator: " .. table.concat(
        vim.tbl_map(function(c)
          return type(c) == "string" and c or table.concat(c, " ")
        end, tasks),
        " | "
      ),
      strategy = {
        "orchestrator",
        tasks = tasks,
      },
      components = {
        { "on_complete_notify", statuses = { "SUCCESS" } },
        "default",
      },
    })
    :start()
end

return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")

      local opts = {
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        signs_staged = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
        },
        signs_staged_enable = true,
        on_attach = function(bufnr)
          -- `bufnr` comes from `on_attach` and ensures the mapping only works in this buffer.

          -- Navigation mappings: move between Git hunks.
          -- ——————————————————————————————————————————————
          map({
            mode = "n",
            lhs = "]g",
            rhs = function()
              if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
              else
                ---@diagnostic disable-next-line: param-type-mismatch
                gitsigns.nav_hunk("next")
              end
            end,
            desc = "Gitsigns: Go to Next Hunk",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "[g",
            rhs = function()
              if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
              else
                ---@diagnostic disable-next-line: param-type-mismatch
                gitsigns.nav_hunk("prev")
              end
            end,
            desc = "Gitsigns: Go to Previous Hunk",
            buffer = bufnr,
          })

          -- Action mappings: stage, reset, undo, preview, diff, blame, and show commit.
          -- —————————————————————————————————————————————————————————————————————————————
          map({
            mode = "n",
            lhs = "<leader>ga",
            rhs = gitsigns.stage_hunk,
            desc = "Gitsigns: Stage Hunk",
            buffer = bufnr,
          })

          map({
            mode = "v",
            lhs = "<leader>ga",
            rhs = function()
              gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end,
            desc = "Gitsigns: Stage Hunk",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gA",
            rhs = gitsigns.stage_buffer,
            desc = "Gitsigns: Stage Entire Buffer",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gr",
            rhs = gitsigns.reset_hunk,
            desc = "Gitsigns: Reset Hunk",
            buffer = bufnr,
          })

          map({
            mode = "v",
            lhs = "<leader>gr",
            rhs = function()
              gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end,
            desc = "Gitsigns: Reset Hunk",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gR",
            rhs = gitsigns.reset_buffer,
            desc = "Gitsigns: Reset Buffer",
            buffer = bufnr,
          })

          -- undo_stage_hunk is depcrated.
          -- Ref: https://github.com/lewis6991/gitsigns.nvim/issues/1180
          map({
            mode = "n",
            lhs = "<leader>gu",
            ---@diagnostic disable-next-line: deprecated
            rhs = gitsigns.undo_stage_hunk,
            desc = "Gitsigns: Undo Staged Hunk",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gp",
            rhs = gitsigns.preview_hunk,
            desc = "Gitsigns: Preview Hunk",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gi",
            rhs = gitsigns.preview_hunk_inline,
            desc = "Gitsigns: Preview Hunk (inline)",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gd",
            rhs = gitsigns.diffthis,
            desc = "Gitsigns: diff vs index",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gD",
            rhs = function()
              ---@diagnostic disable-next-line: param-type-mismatch
              gitsigns.diffthis("~")
            end,
            desc = "Gitsigns: diff vs last commit",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gB",
            rhs = function()
              gitsigns.blame_line({ full = true })
            end,
            desc = "Gitsigns: blame line (full)",
            buffer = bufnr,
          })

          map({
            mode = "n",
            lhs = "<leader>gc",
            rhs = function()
              gitsigns.show_commit()
            end,
            desc = "Gitsigns: Show Commit",
            buffer = bufnr,
          })

          -- Text-object mapping: select hunk.
          -- ———————————————————————————————————
          map({
            mode = { "o", "x" },
            lhs = "ih",
            rhs = gitsigns.select_hunk,
            desc = "Gitsigns: Change in Hunk (text object)",
            buffer = bufnr,
          })
        end,
      }

      require("gitsigns").setup(opts)
    end,
  },
  {
    "tpope/vim-fugitive",
    dependencies = {
      "tpope/vim-rhubarb",
      "junegunn/gv.vim",
      "stevearc/overseer.nvim",
      "folke/snacks.nvim",
    },
    config = function()
      -- Init／Create:
      map({
        mode = "n",
        lhs = "<C-g>i",
        rhs = function()
          local notify_github_title = { title = "GitHub" }

          local is_initialized = git_initialized({ quiet = true })

          local user = github_username()
          if not user then
            return
          end

          -- if is_initialized then
          --   vim.notify(
          --     "Git: project creation cancelled. Project *" .. project .. "* already exists.",
          --     log_warning,
          --     notify_github_title
          --   )
          --   return nil
          -- end

          local directory = get_cwd_basename()

          local github_project_prompt = "What's the name of your GitHub project (default: " .. directory .. ")? "
          vim.ui.input({ prompt = github_project_prompt }, function(project_name_input)
            local project = trim(project_name_input)
            if project == "" then
              project = directory
            end

            local confirmation_prompt = "Create project '" .. project .. "' on GitHub? [y]es／[n]o／[q]uit: "
            vim.ui.input({ prompt = confirmation_prompt }, function(answer)
              local confirm_creation = trim(answer):lower()
              local yes_values = { y = true, ye = true, yes = true, yep = true, ok = true }

              if not yes_values[confirm_creation] then
                vim.notify("Project creation aborted for project **" .. project .. "**", log_info, notify_github_title)
                return
              end

              local gh_exit, _ = run_shell_command("gh repo view '" .. project .. "'")

              if gh_exit == 0 then
                local message = {
                  "Git: project creation cancelled. GitHub project **" .. project .. "** already exists.",
                  "Run `gh repo clone " .. user .. "/" .. project .. "` to download it",
                }
                vim.notify(table.concat(message, "\n\n"), log_info, notify_github_title)
                return
              end

              local commands = {}
              if not is_initialized then
                table.insert(commands, "git init")
              end
              table.insert(commands, 'gh repo create --public "' .. project .. '"')

              overseer_runner(commands)
            end)
          end)
        end,
        desc = "Git (Overseer): initialize & create GitHub repo",
      })

      -- Status:
      map({ mode = "n", lhs = "<C-g>ss", rhs = "Git", desc = "Fugitive: status" })
      map({ mode = "n", lhs = "<C-g>sn", rhs = "Git status -sb", desc = "Fugitive: status (as notification)" })

      -- Staging:
      map({ mode = "n", lhs = "<C-g>a", rhs = "Gwrite", desc = "Fugitive: add file" })

      -- Stage current file → Amend last commit (no edit) → Force push:
      map({
        mode = "n",
        lhs = "<C-g>!",
        rhs = "Gwrite|Git commit --amend --no-edit|Git push --force",
        desc = "Fugitive: stage current file → amend last commit (no edit) → force push",
      })

      -- Stash push:
      map({
        mode = "n",
        lhs = "<C-g>SS",
        rhs = "Git stash --include-untracked",
        desc = "Stash (push): tracked + untracked (default)",
      })

      map({
        mode = "n",
        lhs = "<C-g>Se",
        rhs = "Git stash --all",
        desc = "Stash (push): tracked + untracked + ignored",
      })

      map({
        mode = "n",
        lhs = "<C-g>Sw",
        rhs = "Git stash --keep-index",
        desc = "Stash (push): working (keep staged changes)",
      })

      map({
        mode = "n",
        lhs = "<C-g>SW",
        rhs = "Git stash --keep-index --include-untracked",
        desc = "Stash (push): working + untracked (keep staged changes)",
      })

      -- Stash pop:
      map({ mode = "n", lhs = "<C-g>Sp", rhs = "Git stash pop", desc = "Stash (pop): most recent (default)" })

      map({
        mode = "n",
        lhs = "<C-g>SP",
        rhs = function()
          local index = trim(vim.fn.input("Stash index to pop: "))
          if index ~= "" then
            vim.cmd("Git stash pop " .. index)
          end
        end,
        desc = "Stash (pop): by index <#>",
      })

      -- Stash apply:
      map({ mode = "n", lhs = "<C-g>Sa", rhs = "Git stash apply", desc = "Stash (apply): most recent (default)" })

      map({
        mode = "n",
        lhs = "<C-g>SA",
        rhs = function()
          local index = trim(vim.fn.input("Stash index to pop: "))
          if index ~= "" then
            vim.cmd("Git stash apply " .. index)
          end
        end,
        desc = "Stash (apply): by index <#>",
      })

      -- Remote:
      map(copy_url_mapping_helper("<C-g>rh", "origin", "https"))
      map(copy_url_mapping_helper("<C-g>rH", "upstream", "https"))
      map(copy_url_mapping_helper("<C-g>rs", "origin", "ssh"))
      map(copy_url_mapping_helper("<C-g>rS", "upstream", "ssh"))

      -- stylua: ignore start

      -- Branch / Checkout:
      map({ mode = "n", lhs = "<C-g>bc", rhs = ":<C-u>Git checkout -b ", desc = "Fugitive (checkout): create new <branch>" })
      map({ mode = "n", lhs = "<C-g>b-", rhs = "Git checkout -", desc = "Fugitive (checkout): switch to previous branch" })

      -- stylua: ignore end
      map({
        mode = "n",
        lhs = "<C-g>bb",
        rhs = function()
          local branch = git_branch()
          if not branch then
            return
          end
          vim.notify("Current Git Branch: *" .. branch .. "*", log_info, notify_fugitive_title)
        end,
        desc = "Git (branch): show current",
      })

      map({
        mode = "n",
        lhs = "<C-g>bB",
        rhs = function()
          local branch = git_branch()
          if not branch then
            return
          end

          local hash, summary, body = git_latest_commit()

          local sections = {
            { "**Current Git Branch:**", branch },
            { "**Latest Git Commit:**", hash },
            { "**--- Commit Message ---**", nil },
            { nil, summary },
            { nil, body },
          }

          local lines = {}
          for _, s in ipairs(sections) do
            local label, text = s[1], s[2]
            if text and text:match("%S") then
              table.insert(lines, label and string.format("%s `%s`", label, text) or text)
            elseif label then
              table.insert(lines, label)
            end
          end

          local message = table.concat(lines, "\n\n")

          require("snacks").notifier(message, "info", { timeout = 10000 })
        end,
        desc = "Git (branch): show current w/ latest commit",
      })

      -- stylua: ignore start
      -- Commit:
      map({ mode = "n", lhs = "<C-g>cc", rhs = "Git commit", desc = "Fugitive: commit" })
      map({ mode = "n", lhs = "<C-g>cf", rhs = "Git commit %", desc = "Fugitive: commit (only the current file)" })
      map({ mode = "n", lhs = "<C-g>cv", rhs = "Git commit --verbose", desc = "Fugitive: commit -v" })
      map({ mode = "n", lhs = "<C-g>ca", rhs = "Git commit --amend", desc = "Fugitive: commit --amend" })
      map({ mode = "n", lhs = "<C-g>cA", rhs = "Git commit --amend --verbose", desc = "Fugitive: commit --amend --verbose" })
      map({ mode = "n", lhs = "<C-g>cn", rhs = "Git commit --amend --no-edit", desc = "Fugitive: commit --amend --no-edit" })
      -- stylua: ignore end

      -- An interactive command to amend the author/email of the latest commit:
      map({
        mode = "n",
        lhs = "<C-g>c.",
        rhs = function()
          local hash, _, _ = git_latest_commit()
          if not hash then
            return nil
          end

          local function message_helper(subject)
            return "No " .. subject .. " entered - author update cancelled for commit `" .. hash .. "`"
          end

          vim.ui.input({ prompt = "Author for latest commit (" .. hash .. "): " }, function(author)
            if not author or author:match("^%s*$") then
              vim.notify(message_helper("author"), log_warning, notify_fugitive_title)
              return
            end
            author = trim(author)

            vim.ui.input({ prompt = "Email for " .. author .. ": " }, function(email)
              if not email or email:match("^%s*$") then
                vim.notify(message_helper("email"), log_warning, notify_fugitive_title)
                return
              end

              email = trim(email)
              vim.cmd('Git commit -C HEAD --amend --author="' .. author .. " <" .. email .. '>"')
            end)
          end)
        end,
        desc = "Fugitive: change the author of the latest commit",
      })

      -- Log:
      map({ mode = "n", lhs = "<C-g>ll", rhs = "Git log --oneline", desc = "Fugitive: log --oneline" })

      map({
        mode = "n",
        lhs = "<C-g>lc",
        rhs = "Git log --oneline -- %",
        desc = "Fugitive: log --oneline (current file only)",
      })

      map({ mode = "n", lhs = "<C-g>lL", rhs = "Git log", desc = "Fugitive: log (full)" })

      map({
        mode = "n",
        lhs = "<C-g>lp",
        rhs = "Git log --pretty=oneline -n 20 --graph --abbrev-commit",
        desc = "Fugitive: pretty log (20 latest commits)",
      })

      -- Diff:
      map({
        mode = "n",
        lhs = "<C-g>ds",
        rhs = "Git diff --cached -U0",
        desc = "Fugitive (diff): staged changes - no surrounding context, (+/-) only",
      })

      map({
        mode = "n",
        lhs = "<C-g>dS",
        rhs = "Git diff --cached -U0 -- %",
        desc = "Fugitive (diff): staged changes (current file) - no surrounding context, (+/-) only",
      })

      map({
        mode = "n",
        lhs = "<C-g>dF",
        rhs = "Git diff --cached -W --function-context",
        desc = "Fugitive (diff): with function context",
      })

      map({
        mode = "n",
        lhs = "<C-g>dw",
        rhs = function()
          local hash, _, _ = git_latest_commit()
          if not hash then
            return
          end
          overseer_runner({ "git diff --color-words" })
        end,
        desc = "Git (Overseer): diff --color-words",
      })

      map({
        mode = "n",
        lhs = "<C-g>dm",
        rhs = function()
          local hash, _, _ = git_latest_commit()
          if not hash then
            return
          end
          overseer_runner({ "git diff --color-moved" })
        end,
        desc = "Git (Overseer): diff --color-moved",
      })

      -- Fetch/Pull:
      map({ mode = "n", lhs = "<C-g>ff", rhs = "Git fetch", desc = "Fugitive: fetch" })
      map({ mode = "n", lhs = "<C-g>fp", rhs = "Git pull", desc = "Fugitive: pull" })
      map({ mode = "n", lhs = "<C-g>fr", rhs = "Git pull --rebase", desc = "Fugitive: pull --rebase" })

      -- Push:
      map({ mode = "n", lhs = "<C-g>pp", rhs = "Git push", desc = "Fugitive: push" })
      map({ mode = "n", lhs = "<C-g>pf", rhs = "Git push --force", desc = "Fugitive: push --force" })

      -- An interactive `git push -u origin <current_branch>` implementation:
      --   ∙ Prompts the user for confirmation before pushing the current branch to GitHub.
      --   ∙ Useful for safely publishing new branches without accidentally pushing unintended
      --     changes.
      map({
        mode = "n",
        lhs = "<C-g>pu",
        rhs = function()
          local branch = git_branch()
          if not branch then
            return
          end

          vim.ui.input({ prompt = "Push " .. branch .. " to origin? [y]es／[n]o／[q]uit: " }, function(input)
            local confirm_push = sanitize_input(input)
            local yes_values = { y = true, ye = true, yes = true, yep = true, ok = true }

            if not yes_values[confirm_push] then
              vim.notify("Push cancelled for branch *" .. branch .. "*", log_info, notify_fugitive_title)
              return
            end

            vim.cmd("Git push -u origin '" .. branch .. "'")
          end)
        end,
        desc = "Fugitive: push -u origin <branch>",
      })

      -- Whatchanged:
      map({
        mode = "n",
        lhs = "<C-g>ww",
        rhs = "Git whatchanged --i-still-use-this",
        desc = "Fugitive: whatchanged (workspace)",
      })

      map({
        mode = "n",
        lhs = "<C-g>wb",
        rhs = "Git whatchanged --i-still-use-this -- %",
        desc = "Fugitive: whatchanged (buffer)",
      })

      map({
        mode = "n",
        lhs = "<C-g>wc",
        rhs = ":Git whatchanged --i-still-use-this --since=",
        desc = "Fugitive: whatchanged --since=<date>",
      })

      -- Browse:
      map({ mode = "n", lhs = "<C-g>of", rhs = "GBrowse", desc = "Fugitive: browse (file)" })
      map({ mode = "n", lhs = "<C-g>ol", rhs = ".GBrowse", desc = "Fugitive: browse (line in file)" })

      map({
        mode = "n",
        lhs = { "<C-g>ob", "<C-g>oo" },
        rhs = function()
          vim.fn.system({ "gh", "browse" })
        end,
        desc = "GitHub CLI: browse (repo)",
      })
    end,
  },
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
    keys = {
      { "<C-g>y", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
      { "<C-g>oL", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Git Linker: browse (line in file)" },
    },
  },
  {
    "rhysd/git-messenger.vim",
    config = function()
      -- Ensure the cursor always moves to the popup window after `:GitMessenger` is run.
      vim.g.git_messenger_into_popup_after_show = 1
      vim.g.git_messenger_always_into_popup = 1

      local function git_messenger()
        local bufname = vim.api.nvim_buf_get_name(0)

        -- Check that current file is in a git repository:
        if not git_initialized() then
          return
        end

        local exit_code, _ = run_shell_command(
          "git ls-files --error-unmatch " .. vim.fn.fnameescape(bufname),
          function()
            vim.notify(
              "File `" .. bufname .. "` is not tracked by *" .. git_project_name() .. "*",
              vim.log.levels.WARN,
              { title = "Git Messenger" }
            )
          end
        )

        if exit_code ~= 0 then
          return
        end

        vim.cmd("GitMessenger")
      end

      map({
        mode = "n",
        lhs = "<leader>gm",
        rhs = git_messenger,
        desc = "Git Messenger: toggle",
      })
    end,
  },
  {
    -- TODO: git-blame: put this somewhere so that it's only available when attached to a git project. (E.g. on_attach)
    "f-person/git-blame.nvim",
    config = function()
      map({ mode = "n", lhs = "<C-g>bt", rhs = "GitBlameToggle", desc = "Git Blame: toggle virtual text" })
      map({ mode = "n", lhs = "<C-g>by", rhs = "GitBlameCopySHA", desc = "Git Blame: copy commit SHA" })
      map({ mode = "n", lhs = "<C-g>bo", rhs = "GitBlameOpenCommitURL", desc = "Git Blame: open commit URL" })
      map({ mode = "n", lhs = "<C-g>bO", rhs = "GitBlameCopyCommitURL", desc = "Git Blame: copy commit URL" })
    end,
  },
  {
    {
      "nvim-telescope/telescope.nvim",
      config = function()
        require("telescope").setup({
          defaults = {
            layout_config = {
              preview_width = 0.5,
              width = 0.9,
              height = 0.9,
            },
          },
        })
      end,
    },
    {
      "pwntester/octo.nvim",
      requires = {
        "nvim-lua/plenary.nvim",
        "folke/snacks.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
      },
      config = function()
        require("octo").setup({
          -- picker = "snacks",
          -- default_merge_method = "commit",
        })

        map({ mode = "n", lhs = "<leader>ghg", rhs = "Octo gist list", desc = "GitHub (Octo): list gists" })
        map({ mode = "n", lhs = "<leader>ghi", rhs = "Octo issue list", desc = "GitHub (Octo): list issues" })
        map({ mode = "n", lhs = "<leader>ghm", rhs = "Octo pr merge", desc = "GitHub (Octo): merge pull request" })
        map({ mode = "n", lhs = "<leader>ghn", rhs = "Octo notification", desc = "GitHub (Octo): notifications" })
        map({ mode = "n", lhs = "<leader>ghp", rhs = "Octo pr list", desc = "GitHub (Octo): list pull requests" })
        map({ mode = "n", lhs = "<leader>ghr", rhs = "Octo repo list", desc = "GitHub (Octo): list repos" })
        map({ mode = "n", lhs = "<leader>ghw", rhs = "Octo run list", desc = "GitHub (Octo): list workflow runs" })
      end,
    },
  },
}
