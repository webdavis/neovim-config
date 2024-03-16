return {
  "wojciech-kulik/xcodebuild.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local progress_handle

    require("xcodebuild").setup({
      auto_save = true,
      restore_on_start = true,
      show_build_progress_bar = true,
      test_explorer = {
        auto_open = false, -- open Test Explorer when tests are started
        auto_focus = false,
      },
      logs = {
        auto_open_on_success_tests = false,
        auto_open_on_failed_tests = true,
        auto_open_on_success_build = false,
        auto_open_on_failed_build = true,
        auto_focus = false,
        auto_close_on_app_launch = true,
        only_summary = true,
        notify = function(message, severity)
          local fidget = require("fidget")
          if progress_handle then
            progress_handle.message = message
            if not message:find("Loading") then
              progress_handle:finish()
              progress_handle = nil
              if vim.trim(message) ~= "" then
                vim.notify(message, severity)
              end
            end
          else
            fidget.notify(message, severity)
          end
        end,
        notify_progress = function(message)
          local progress = require("fidget.progress")

          if progress_handle then
            progress_handle.title = ""
            progress_handle.message = message
          else
            progress_handle = progress.handle.create({
              message = message,
              lsp_client = { name = "xcodebuild.nvim" },
            })
          end
        end,
      },
      code_coverage = {
        enabled = true,
      },
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "XcodebuildCoverageToggled",
      callback = function(event)
        local isOn = event.data
        require("gitsigns").toggle_signs(not isOn)
      end,
    })

    -- stylua: ignore start
    local map = require("config.custom_api").map

    map("n", "<M-x>", "XcodebuildPicker", "xcodebuild - show xcodebuild actions")
    map("n", "<leader><space>o", "XcodebuildOpenInXcode", "xcodebuild - open project in Xcode")
    map("n", "<leader><space>a", "XcodebuildCodeActions", "xcodebuild - code actions (current line)")

    ------------------------
    -- Cancel/clean mappings
    ------------------------
    map("n", "<leader><space>0", "XcodebuildCancel", "xcodebuild - cancel currently running action")
    map("n", "<leader><space><bs>", "XcodebuildCleanDerivedData", "xcodebuild - delete project's derived data")

    ---------------------
    -- Build/run mappings
    ---------------------
    map("n", "<leader><space>b", "XcodebuildBuild", "xcodebuild - build project")
    map("n", "<leader><space>B", "XcodebuildCleanBuild", "xcodebuild - clean build")
    map("n", "<leader><space><cr>", "XcodebuildBuildRun", "xcodebuild - build & run project")
    map("n", "<leader><space>r", "XcodebuildRun", "xcodebuild - run project")

    ---------------
    -- Log mappings
    ---------------
    map("n", "<leader><space>l", "XcodebuildToggleLogs", "xcodebuild - toggle logs panel")

    ---------------------------------
    -- Test mappings <leader><space>,
    ---------------------------------
    map("n", "<leader><space>;", "XcodebuildTest", "xcodebuild - run tests (whole test plan)")
    map("v", "<leader><space>;", "XcodebuildTestSelected", "xcodebuild - run selected tests (whole test plan)")
    map("n", "<leader><space>e", "XcodebuildTestExplorerToggle", "xcodebuild - toggle test explorer")

    map("n", "<leader><space>,,", "XcodebuildBuildForTesting", "xcodebuild - build for testing")
    map("n", "<leader><space>,c", "XcodebuildTestClass", "xcodebuild - run this test class")
    map("n", "<leader><space>,f", "XcodebuildTestFunc", "xcodebuild - run test under cursor")

    map("n", "<leader><space>,s", "XcodebuildFailingSnapshots", "xcodebuild - show failing snapshots")
    map("n", "<leader><space>,c", "XcodebuildToggleCodeCoverage", "xcodebuild - toggle code coverage marks")
    map("n", "<leader><space>,r", "XcodebuildShowCodeCoverageReport", "xcodebuild - show code coverage report")

    -----------------------------------
    -- Config mappings <leader><space>c
    -----------------------------------
    map("n", "<leader><space>c0", "XcodebuildSetup", "xcodebuild - setup")
    map("n", "<leader><space>c;", "XcodebuildShowConfig", "xcodebuild - print current project config")
    map("n", "<leader><space>cm", "XcodebuildProjectManager", "xcodebuild - show project manager actions")

    map("n", "<leader><space>cd", "XcodebuildSelectDevice", "xcodebuild - select device")
    map("n", "<leader><space>cb", "XcodebuildBootSimulator", "xcodebuild - boot simulator")
    map("n", "<leader><space>ct", "XcodebuildSelectTestPlan", "xcodebuild - select test plan")
    map("n", "<leader><space>cs", "XcodebuildSelectScheme", "xcodebuild - select scheme")
    map("n", "<leader><space>cp", "XcodebuildSelectProject", "xcodebuild - select project")
    map("n", "<leader><space>cc", "XcodebuildSelectConfig", "xcodebuild - select config")
  end,
}
