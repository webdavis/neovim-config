return {
  "krisajenkins/telescope-docker.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("telescope").load_extension("telescope_docker")
    require("telescope_docker").setup({})

    -- Example keybindings. Adjust these to suit your preferences or remove
    --   them entirely:
    vim.keymap.set("n", "<Leader>dv", ":Telescope telescope_docker docker_volumes<CR>", { desc = "Docker volumes" })
    vim.keymap.set("n", "<Leader>di", ":Telescope telescope_docker docker_images<CR>", { desc = "Docker images" })
    vim.keymap.set("n", "<Leader>dp", ":Telescope telescope_docker docker_ps<CR>", { desc = "Docker processes" })
  end,
}
