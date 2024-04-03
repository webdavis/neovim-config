return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux",
  },
  config = function()
    vim.cmd("let test#strategy = 'vimux'")
    local map = require("config.custom_api").map
    map("n", "<leader>tN", "TestNearest", "vim-test - run nearest test")
    map("n", "<leader>tF", "TestFile", "vim-test - run test file")
    map("n", "<leader>t:", "TestSuite", "vim-test - run test suite")
    map("n", "<leader>tL", "TestLast", "vim-test - run last test")
    map("n", "<leader>tg", "TestVisit", "vim-test - goto test")
  end,
}
