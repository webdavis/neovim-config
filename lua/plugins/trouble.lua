return {
  "folke/trouble.nvim",
  config = function()
    local trouble = require("trouble")

    trouble.setup({
      icons = false,
      auto_preview = false,
    })

    -- vim.api.nvim_create_autocmd("User", {
    --   pattern = { "XcodebuildBuildFinished", "XcodebuildTestsFinished" },
    --   callback = function(event)
    --     if event.data.cancelled then
    --       return
    --     end
    --
    --     if event.data.success then
    --       trouble.close()
    --     elseif not event.data.failedCount or event.data.failedCount > 0 then
    --       if next(vim.fn.getqflist()) then
    --         trouble.open({ focus = false })
    --       else
    --         trouble.close()
    --       end
    --
    --       trouble.refresh()
    --     end
    --   end,
    -- })

    local map = require("config.custom_api").map

    map("n", "<M-t>", function()
      trouble.toggle()
    end, "trouble - list buffer diagnostics")

    map("n", "<M-w>", "TroubleToggle workspace_diagnostics", "trouble - list workspace diagnostics")
    map("n", "<leader>tr", "Trouble lsp_references", "trouble - list LSP references for <cword>")

    map("n", "[r", function()
      trouble.next({ skip_groups = true, jump = true })
    end, "trouble - jump to previous")

    map("n", "]r", function()
      trouble.previous({ skip_groups = true, jump = true })
    end, "trouble - jump to next")
  end,
}
