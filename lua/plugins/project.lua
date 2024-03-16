return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      patterns = {
        ".bzr",
        ".git",
        ".hg",
        ".svn",
        ".tests",
        "Makefile",
        "_darcs",
        "justfile",
        "package.json",
      },
    })
  end,
}
