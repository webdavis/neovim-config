return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup({})
    -- REQUIRED

    local map = require("config.custom_api").map

    map("n", "<leader>h", function()
      harpoon:list():append()
    end, { desc = "harpoon - add buffer to harpoon list" })

    map("n", "<leader>k", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "harpoon - show all buffers" })

    -- Toggle previous & next buffers stored within Harpoon list
    map("n", "<C-p>", function()
      harpoon:list():prev()
    end)
    map("n", "<C-n>", function()
      harpoon:list():next()
    end)
  end,
}
