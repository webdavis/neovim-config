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

local git_user = function()
  local handle = io.popen("git config user.name 2>/dev/null")
  if not handle then
    return nil
  end

  local user = trim(handle:read("*a"))
  handle:close()

  if user == "" then
    vim.notify("Git Warning: could not identify git user", log_warning, notify_fugitive_title)
    return nil
  end

  return user
end

local git_initialized = function()
  local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
  if not handle then
    return false
  end

  local output = trim(handle:read("*a"))
  handle:close()

  return output == "true"
end

local git_project = function()
  local cwd = get_cwd_basename()

  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if not handle then
    vim.notify(
      "Git Warning: current directory (*" .. cwd .. "*) is not in a Git project.\nTry 'git init' to start a project",
      log_warning,
      notify_fugitive_title
    )
    return nil
  end

  local git_root = trim(handle:read("*a"))
  handle:close()

  if git_root == "" then
    vim.notify("Git Error: unable to detect the Git project root.", log_error, notify_fugitive_title)
    return nil
  end

  -- Extract project name from the Git root folder.
  local repo_name = vim.fn.fnamemodify(git_root, ":t")
  if repo_name == "" then
    vim.notify(
      "Git Error: unable to determine Git project name from path: *" .. git_root .. "*",
      log_error,
      notify_fugitive_title
    )
    return nil
  end

  return repo_name
end

local function git_current_branch()
  local cwd = get_cwd_basename()

  local handle = io.popen("git branch --show-current")
  if not handle then
    vim.notify(
      "Terminating: currently in the *" .. cwd .. "* directory, which is not tracked by Git.",
      log_warning,
      notify_fugitive_title
    )
    return nil
  end

  local branch = trim(handle:read("*a"))
  handle:close()

  if branch == "" then
    vim.notify("Error: unable to detect current git branch", log_error, notify_fugitive_title)
    return nil
  end

  return branch
end

local function git_last_commit()
  -- Safety checks:
  local project = git_project()
  if not project then
    return nil, nil, nil
  end

  local branch = git_current_branch()
  if not branch then
    return nil, nil, nil
  end

  local rev_parse_handle = io.popen("git rev-parse HEAD")
  if not rev_parse_handle then
    vim.notify(
      "Terminating: unable to find the latest commit. This may occur if no commits have been made to *"
        .. project
        .. "* yet.",
      log_warning,
      notify_fugitive_title
    )
    return nil, nil, nil
  end

  local commit_hash = trim(rev_parse_handle:read("*a"))
  rev_parse_handle:close()

  if commit_hash == "" then
    vim.notify("Error: Unable to detect last git commit on " .. branch, log_error, notify_fugitive_title)
    return nil, nil, nil
  end

  local log_handle = io.popen("git log -1 --pretty=%B")
  if not log_handle then
    return commit_hash, nil, nil
  end

  local commit_message = trim(log_handle:read("*a") or "")
  log_handle:close()
  local commit_summary, commit_body = commit_message:match("([^\n]*)\n?(.*)")
  commit_summary = (commit_summary ~= "" and trim(commit_summary)) or nil
  commit_body = (commit_body ~= "" and trim(commit_body)) or nil

  return commit_hash, commit_summary, commit_body
end

local git_overseer = function(cmds)
  -- Safety checks:
  if not git_project() then
    return nil
  end
  if not git_current_branch() then
    return nil
  end

  -- If cmds is a single string, convert to table
  if type(cmds) == "string" then
    cmds = { cmds }
  end

  -- Build orchestrator subtasks:
  local tasks = {}
  for _, cmd in ipairs(cmds) do
    if type(cmd) == "string" then
      -- simple shell command
      table.insert(tasks, cmd)
    elseif type(cmd) == "table" then
      -- assume table has { cmd, ...options }
      table.insert(tasks, cmd)
    end
  end

  -- Create the orchestrator task:
  require("overseer")
    .new_task({
      name = "Git Orchestrator: " .. table.concat(
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
    },
    config = function()
      -- Init／Create:
      map({
        mode = "n",
        lhs = "<C-g>i",
        rhs = function()
          local notify_github_title = { title = "GitHub" }

          local project = git_project()
          if project then
            vim.notify(
              "Git: project creation cancelled. Project *" .. project .. "* already exists.",
              log_warning,
              notify_github_title
            )
            return nil
          end

          local user = git_user()
          if not user then
            return
          end

          local directory = get_cwd_basename()

          local github_project_prompt = "What's the name of your GitHub project (default: " .. directory .. ")? "
          vim.ui.input({ prompt = github_project_prompt }, function(project_name_input)
            local project_name = trim(project_name_input)
            if project_name == "" then
              project_name = directory
            end

            local confirmation_prompt = "Create project '" .. project_name .. "' on GitHub? [y]es／[n]o／[q]uit: "
            vim.ui.input({ prompt = confirmation_prompt }, function(answer)
              local confirm_creation = trim(answer):lower()
              local yes_values = { y = true, ye = true, yes = true, yep = true, ok = true }

              if not yes_values[confirm_creation] then
                vim.notify("Project creation aborted for repo *" .. project_name .. "*", log_info, notify_github_title)
                return
              end

              local git_init_needed = not git_initialized()

              local handle_gh = io.popen("gh repo view '" .. project_name .. "' 2>/dev/null")
              local gh_exists = handle_gh and trim(handle_gh:read("*a")) ~= ""
              if handle_gh then
                handle_gh:close()
              end

              if gh_exists then
                vim.notify("GitHub repo *" .. project_name .. "* already exists.", log_info, notify_github_title)
                return
              end

              local commands = {}
              if git_init_needed then
                table.insert(commands, "git init")
              end
              table.insert(commands, 'gh repo create --public "' .. project_name .. '"')

              git_overseer(commands)
            end)
          end)
        end,
        desc = "Git (Overseer): init & create repo on GitHub",
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

      -- Commit:
      -- stylua: ignore start
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
          local last_commit = git_last_commit()
          if not last_commit then
            return nil
          end

          vim.ui.input({ prompt = "Author for last commit (" .. last_commit .. "): " }, function(author)
            if not author or author:match("^%s*$") then
              vim.notify("Cancelled: no author entered", log_warning, notify_fugitive_title)
              return
            end
            author = trim(author)

            vim.ui.input({ prompt = "Email for " .. author .. ": " }, function(email)
              if not email or email:match("^%s*$") then
                vim.notify("Cancelled: no email entered", log_warning, notify_fugitive_title)
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
          git_overseer({ "git diff --color-words" })
        end,
        desc = "Git (Overseer): diff --color-words",
      })

      map({
        mode = "n",
        lhs = "<C-g>dm",
        rhs = function()
          git_overseer({ "git diff --color-moved" })
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
          local branch = git_current_branch()
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
        vim.fn.system("git rev-parse --is-inside-work-tree")
        if vim.v.shell_error ~= 0 then
          vim.notify(
            "No git repository found for current file: `" .. bufname .. "`",
            vim.log.levels.WARN,
            { title = "Git Messenger" }
          )
          return
        end

        local repo = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or "unknown_repo"

        -- Check that current file is tracked by git:
        vim.fn.system("git ls-files --error-unmatch " .. vim.fn.fnameescape(bufname))
        if vim.v.shell_error ~= 0 then
          vim.notify(
            "File `" .. bufname .. "` is not tracked by *" .. repo .. "*",
            vim.log.levels.WARN,
            { title = "Git Messenger" }
          )
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
