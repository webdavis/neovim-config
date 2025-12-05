-- ╭─────────────╮
-- │   Modules   │
-- ╰─────────────╯
local git = require("custom_api.git")
local github = require("custom_api.github")
local util = require("custom_api.util")

local run_shell_command = util.run_shell_command
local trim = util.trim
local sanitize_input = util.sanitize_input
local overseer_runner = util.overseer_runner

-- ╭─────────────╮
-- │   Helpers   │
-- ╰─────────────╯
local log_info = vim.log.levels.INFO
local log_trace = vim.log.levels.TRACE
local log_warning = vim.log.levels.WARN
local log_error = vim.log.levels.INFO
local notify_fugitive_title = { title = "Fugitive" }
local notify_github_title = { title = "GitHub" }

local function copy_url_mapping_helper(lhs, remote, protocol)
  local mapping_table = {
    mode = "n",
    lhs = lhs,
    rhs = function()
      if git.initialized() then
        local url = git.url({
          remote = remote,
          account_name = github.account(),
          repo_name = github.repo(),
        })

        if not url then
          vim.notify("Warning: Nothing copied to clipboard!", log_warning, { title = "git" })
          return
        end

        local message = git.copy_URL_to_clipboard({
          url = url,
          remote = remote,
          protocol = protocol,
        })

        if message then
          vim.notify(message, log_info, { title = "git" })
        end
      end
    end,
    desc = "Git (remote): copy " .. protocol:upper() .. " URL (" .. remote .. ")",
  }

  return mapping_table
end

-- ╭─────────────╮
-- │   Plugins   │
-- ╰─────────────╯
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
          local is_initialized = git.initialized({ quiet = true })

          local user = github.username()
          if not user then
            return
          end

          local directory = util.get_cwd_basename()

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

              local gh_exit, _ = run_shell_command({ cmd = "gh repo view '" .. project .. "'" })

              if gh_exit == 0 then
                local message = {
                  "Git: project creation cancelled. GitHub project **" .. project .. "** already exists.",
                  "Run `gh repo clone " .. user .. "/" .. project .. "` to download it",
                }
                vim.notify(table.concat(message, "\n\n"), log_info, notify_github_title)
                return
              end

              local cmds = {}
              if not is_initialized then
                table.insert(cmds, "git init")
              end
              table.insert(cmds, 'gh repo create --public "' .. project .. '"')

              overseer_runner({ cmds = cmds })
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
      map({
        mode = "n",
        lhs = "<C-g>bc",
        rhs = function()
          local repo = github.repo()
          if not repo then
            return
          end

          local branch = git.current_branch()

          local prompt
          if branch.name and branch.hash then
            prompt = ("%s: checkout new branch from '%s' (commit: %s): "):format(
              repo,
              branch.name,
              branch.hash
            )
          elseif branch.name then
            prompt = ("%s: checkout new branch from '%s': "):format(
              repo,
              branch.name
            )
          else
            prompt = ("%s: checkout new branch (no commit detected): "):format(repo)
          end

          vim.ui.input({ prompt = prompt }, function(new_branch)
            if not new_branch or new_branch:match("^%s*$") then
              local cancel_message = string.format(
                "Branch checkout cancelled in repo `%s`: no branch entered.",
                repo
              )
              vim.notify(cancel_message, log_warning, notify_fugitive_title)
              return
            end
            new_branch = trim(new_branch)

            local cmd = "Git checkout -b " .. new_branch
            vim.cmd(cmd)
          end)

        end,
        desc = "Fugitive (checkout): create new <branch>",
      })

      map({ mode = "n", lhs = "<C-g>b-", rhs = "Git checkout -", desc = "Fugitive (checkout): switch to previous branch" })
      -- stylua: ignore end

      map({
        mode = "n",
        lhs = "<C-g>bb",
        rhs = function()
          local branch = git.current_branch().name
          if not branch then
            return
          end
          vim.notify("**Current Branch:** `" .. branch .. "`", log_info, { title = "Active Git Branch" })
        end,
        desc = "Git (branch): show current",
      })

      local function format_section(label, text, metatext)
        if text and text:match("%S") then
          if metatext and metatext:match("%S") then
            return label and string.format("*%s* [%s] (%s)", label, text, metatext) or text
          else
            return label and string.format("*%s* [%s]", label, text) or text
          end
        elseif label then
          return label
        end
      end

      local function build_sections(branch, commit_hash, summary, body)
        local sections = {}

        if summary then
          table.insert(sections, { "\n" .. summary })
          if body then
            table.insert(sections, { "\n" .. body })
          end
          table.insert(sections, { "\n---------------------------------------" })
        end

        table.insert(sections, { "Branch:", "**" .. branch.name .. "**" })

        if commit_hash then
          table.insert(sections, { "Commit:", commit_hash, "copied to clipboard" })
          util.copy_to_system_clipboard(commit_hash)
        end

        if branch.upstream then
          table.insert(sections, { "Upstream:", branch.upstream })
        end

        return sections
      end

      local function sections_to_message(sections)
        local lines = {}
        for _, s in ipairs(sections) do
          local line = format_section(s[1], s[2], s[3])
          if line then
            table.insert(lines, line)
          end
        end
        return table.concat(lines, "\n")
      end

      local function show_git_branch()
        local branch = git.current_branch()
        if not branch then
          return
        end

        local hash, summary, body = git.latest_commit({ repo_name = github.repo() })
        local sections = build_sections(branch, hash, summary, body)
        local message = sections_to_message(sections)

        vim.notify(message, vim.log.levels.INFO, { title = "Active Git Branch", timeout = 0 })
      end

      map({
        mode = "n",
        lhs = "<C-g>bB",
        rhs = show_git_branch,
        desc = "Git (branch): show current + commit (copy hash to +)",
      })

      local function format_branch(branch)
        local lines = { ("*Branch:* `%s`"):format(branch.name) }

        if branch.hash then
          table.insert(lines, "*Hash:* " .. branch.hash)
        end

        if branch.upstream then
          table.insert(lines, "*Upstream:* " .. branch.upstream)
        end

        if branch.message then
          table.insert(lines, "*Message:* " .. branch.message)
        end

        return table.concat(lines, "\n")
      end

      local function show_all_branches()
        local all_branches = git.all_branches()
        if not all_branches or #all_branches == 0 then
          return
        end

        local nonactive_branches = {}

        for i, branch in ipairs(all_branches) do
          local formatted = format_branch(branch)

          if i == 1 then
            vim.notify(formatted, log_info, { title = "Active Git Branch", timeout = 0 })
          else
            table.insert(nonactive_branches, formatted)
          end
        end

        if #nonactive_branches > 0 then
          vim.notify(
            table.concat(nonactive_branches, "\n\n"),
            log_trace,
            { title = "Inactive Git Branch(es)", timeout = 0 }
          )
        end
      end

      map({
        mode = "n",
        lhs = "<C-g>ba",
        rhs = show_all_branches,
        desc = "Git (branch): show all branches",
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

      map({
        mode = "n",
        lhs = "<C-g>cp",
        rhs = function()
          local _, summary, body = git.latest_commit({ repo_name = github.repo() })
          if not summary then
            return
          end

          vim.fn.setreg('"', summary .. "\n\n" .. (body or ""))
          vim.cmd("normal! ]p")
        end,
        desc = "Fugitive: read latest commit into buffer",
      })

      -- An interactive command to amend the author/email of the latest commit:
      map({
        mode = "n",
        lhs = "<C-g>c.",
        rhs = function()
          local hash, _, _ = git.latest_commit({ repo_name = github.repo() })
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
      map({ mode = "n", lhs = "<C-g>lo", rhs = "Git log --oneline", desc = "Fugitive: log --oneline" })
      map({ mode = "n", lhs = "<C-g>ll", rhs = "Git log", desc = "Fugitive: log" })

      map({
        mode = "n",
        lhs = "<C-g>lc",
        rhs = "Git log --oneline -- %",
        desc = "Fugitive: log --oneline (current file only)",
      })

      map({
        mode = "n",
        lhs = "<C-g>lp",
        rhs = function()
          local branch = git.current_branch().name
          local default_commits = 20
          vim.ui.input(
            { prompt = ("(Branch: %s) Number of commits [default %d, q to quit]: "):format(branch, default_commits) },
            function(input)
              local sanitized = sanitize_input(input or "")

              if sanitized:lower() == "q" then
                vim.notify(("Cancelled Git log for branch `%s`"):format(branch), log_info, notify_fugitive_title)
                return
              end

              if sanitized == "" then
                sanitized = tostring(default_commits)
              end

              local number_commits = tonumber(sanitized)
              if not number_commits or number_commits <= 0 then
                vim.notify(("Invalid number entered: `%s`"):format(sanitized), log_error, notify_fugitive_title)
                return
              end

              vim.notify(
                ("Showing the **%s** most recent commits on branch `%s`"):format(sanitized, branch),
                log_info,
                notify_fugitive_title
              )
              vim.cmd(("Git log --pretty=oneline -n %d --graph --abbrev-commit"):format(number_commits))
            end
          )
        end,
        desc = "Fugitive: pretty log (enter number of commits)",
      })

      -- Diff:
      map({
        mode = "n",
        lhs = "<C-g>dd",
        rhs = "Gvdiffsplit!",
        desc = "Fugitive (diff): file vs staged/commit (vertical)",
      })

      map({
        mode = "n",
        lhs = "<C-g>dD",
        rhs = "Ghdiffsplit!",
        desc = "Fugitive (diff): file vs staged/commit (horizontal)",
      })

      map({
        mode = "n",
        lhs = "<C-g>ds",
        rhs = "Git diff --cached -U0",
        desc = "Git (diff): staged changes (no ctx) (all files)",
      })

      map({
        mode = "n",
        lhs = "<C-g>dS",
        rhs = "Git diff --cached -U0 -- %",
        desc = "Git (diff): staged changes (no ctx) (current file)",
      })

      map({
        mode = "n",
        lhs = "<C-g>df",
        rhs = "vertical Git diff -W --function-context",
        desc = "Fugitive (diff): commit (with function context)",
      })

      map({
        mode = "n",
        lhs = "<C-g>dF",
        rhs = "vertical Git diff --cached -W --function-context",
        desc = "Fugitive (diff): staged (with function context)",
      })

      map({
        mode = "n",
        lhs = "<C-g>dw",
        rhs = function()
          local hash, _, _ = git.latest_commit({ repo_name = github.repo() })
          if not hash then
            return
          end
          overseer_runner({ cmds = "git diff --color-words" })
        end,
        desc = "Git (Overseer): highlight changed words",
      })

      map({
        mode = "n",
        lhs = "<C-g>dm",
        rhs = function()
          local hash, _, _ = git.latest_commit({ repo_name = github.repo() })
          if not hash then
            return
          end
          overseer_runner({ cmds = "git diff --color-moved" })
        end,
        desc = "Git (Overseer): highlight moved lines",
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
          local branch = git.current_branch().name
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
          run_shell_command({ cmd = "gh browse" })
        end,
        desc = "GitHub CLI: open repo Homepage (Code tab)",
      })

      local function open_github_page_mapping(key, suffix, page_desc)
        if not page_desc then
          page_desc = string.gsub(" " .. suffix, "%W%l", string.upper):sub(2)
        end

        local mapping_table = {
          mode = "n",
          lhs = "<C-g>o" .. key,
          rhs = function()
            if not git.initialized() then
              return
            end

            local url = "https://github.com/" .. github.repo({ owner = true }) .. "/" .. suffix
            run_shell_command({ cmd = "open " .. url })
          end,
          desc = "GitHub CLI: open " .. page_desc .. " page",
        }

        return mapping_table
      end

      map(open_github_page_mapping("i", "issues"))
      map(open_github_page_mapping("p", "pulls", "Pull Requests"))
      map(open_github_page_mapping("a", "actions"))
      map(open_github_page_mapping("P", "projects"))
      map(open_github_page_mapping("w", "wiki"))
      map(open_github_page_mapping("S", "security"))
      map(open_github_page_mapping("I", "pulse", "Insights"))
      map(open_github_page_mapping("s", "settings"))
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

        if not git.initialized() then
          return
        end

        local exit_code, _ = run_shell_command({ cmd = "git ls-files --error-unmatch " .. vim.fn.fnameescape(bufname) })

        if exit_code ~= 0 then
          vim.notify(
            "File `" .. bufname .. "` is not tracked by *" .. github.repo() .. "*",
            log_warning,
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
          suppress_missing_scope = {
            projects_v2 = true,
          },
          default_merge_method = "merge",
          picker = "snacks",
          enable_builtin = true,
          picker_config = {
            use_emojis = false, -- Only used by "fzf-lua" picker for now.
            mappings = { -- mappings for the pickers
              open_in_browser = { lhs = "<C-b>", desc = "Octo: open issue in browser" },
              copy_url = { lhs = "<C-y>", desc = "Octo: copy url to system clipboard" },
              copy_sha = { lhs = "<C-e>", desc = "Octo: copy commit SHA to system clipboard" },
              checkout_pr = { lhs = "<C-o>", desc = "Octo: checkout pull request" },
              merge_pr = { lhs = "<C-r>", desc = "Octo: merge pull request" },
            },
          },
        })

        map({ mode = "n", lhs = "<leader>ghg", rhs = "Octo gist list", desc = "Octo: list gists" })
        map({ mode = "n", lhs = "<leader>ghi", rhs = "Octo issue list", desc = "Octo: list issues" })
        map({ mode = "n", lhs = "<leader>ghI", rhs = "Octo issue create", desc = "Octo: create issue" })
        map({ mode = "n", lhs = "<leader>ghm", rhs = "Octo pr merge", desc = "Octo: merge pull request" })
        map({ mode = "n", lhs = "<leader>ghn", rhs = "Octo notification", desc = "Octo: notifications" })
        map({ mode = "n", lhs = "<leader>ghp", rhs = "Octo pr list", desc = "Octo: list pull requests" })
        map({ mode = "n", lhs = "<leader>ghr", rhs = "Octo repo list", desc = "Octo: list repos" })
        map({ mode = "n", lhs = "<leader>ghw", rhs = "Octo run list", desc = "Octo: list workflow runs" })

        local opts = {
          prefix = "<localleader>",
          buffer = 0, -- Target the current buffer
          mode = "n", -- Normal mode
        }

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "octo",
          callback = function()
            local wk = require("which-key")
            wk.add({
              { "<localleader>a", group = "Assignee" },
              { "<localleader>c", group = "Comment" },
              { "<localleader>i", group = "Issue" },
              { "<localleader>g", group = "Navigate" },
              { "<localleader>l", group = "Label" },
              { "<localleader>p", group = "PR" },
              { "<localleader>r", group = "React" },
              { "<localleader>v", group = "Review" },
            }, opts)
          end,
        })
      end,
    },
  },
}
