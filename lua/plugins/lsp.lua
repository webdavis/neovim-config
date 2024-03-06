return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { "folke/neodev.nvim", opts = {} },
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    'hrsh7th/cmp-calc',
    'lukas-reineke/cmp-rg',
    'petertriho/cmp-git',
    'j-hui/fidget.nvim',
    'folke/neodev.nvim',

    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
  },

  opts = {
    -- options for vim.diagnostic.config()
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
        -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        -- prefix = "icons",
      },
      severity_sort = true,
    },
    -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
    -- Be aware that you also will need to properly configure your LSP server to
    -- provide the inlay hints.
    inlay_hints = {
      enabled = false,
    },
    -- add any global capabilities here
    capabilities = {},
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    -- LSP Server Settings
    servers = {
      pyright = {},
      ruff_lsp = {
        keys = {
          {
            "<leader>co",
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = {
                  only = { "source.organizeImports" },
                  diagnostics = {},
                },
              })
            end,
            desc = "code-action - organize imports",
          },
        },
      },
    },
    lua_ls = {
      -- mason = false, -- set to false if you don't want this server to be installed with mason
      -- Use this to add any additional keymaps
      -- for specific lsp servers
      ---@type LazyKeysSpec[]
      -- keys = {},
      settings = {
        Lua = {
          workspace = {
            checkThirdParty = false,
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    },

  },
  -- You can do any additional LSP server setup here.
  setup = {
    ruff_lsp = function()
      require("lazyvim.util").lsp.on_attach(function(client, _)
        if client.name == "ruff_lsp" then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end
      end)
    end,
  },
  config = function()
    -- IMPORTANT: make sure to setup neodev BEFORE lspconfig.
    require("neodev").setup({
      -- Add any options here, or leave empty to use the default settings.
    })

    -- Then setup your lsp server as usual.
    local lspconfig = require('lspconfig')

    -- Example to setup lua_ls and enable call snippets.
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace"
          }
        }
      }
    })

    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local capabilities = vim.tbl_deep_extend(
      'force',
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())

    require('fidget').setup({})
    require('mason').setup()
    require('mason-lspconfig').setup({
      ensure_installed = {
        'ansiblels',
        'bashls',
        'clangd',
        'docker_compose_language_service',
        'dockerls',
        'html',
        'lua_ls',
        'pyright',
        'rust_analyzer',
        'terraformls',
        'tflint',
        'tsserver',
        'zls',
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities
          }
        end,

        ['lua_ls'] = function()
          local lspconfig = require('lspconfig')
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { 'vim', 'it', 'describe', 'before_each', 'after_each' },
                }
              }
            }
          }
        end,
      }
    })

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-i>'] = cmp.mapping.confirm({ select = true }),
        ['<C-e>'] = cmp.config.disable,
        ['<C-c>'] = function(fallback)
          cmp.abort()
          fallback()
        end,
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
        { name = 'calc' },
        { name = 'git' },
        { name = 'rg' },
      }, {
        { name = 'buffer' },
      })
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = true,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
      },
    })

    require('lspconfig').ansiblels.setup({
      filetypes = { 'yaml', 'ansible', 'yaml.ansible' }
    })

    require('lspconfig').bashls.setup({
      filetypes = { 'sh' },
      -- Launch the bashls server explicitly with :LspStart
      autostart = false,
    })

    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = 'diagnostics - show in floating window' })
    vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'diagnostics - show in loclist' })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'diagnostics - goto previous' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'diagnostics - goto next' })

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        ------------------------
        -- Buffer local mappings
        ------------------------
        -- See `:help vim.lsp.*` for documentation on any of the below functions.

        vim.keymap.set('n', 'K', vim.lsp.buf.hover,
          { buffer = ev.buf, desc = 'lsp - display symbol info in hover window ' })

        vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end,
          { buffer = ev.buf, desc = 'lsp - format buffer' })
        vim.keymap.set('n', '<leader>ls', vim.lsp.buf.signature_help,
          { buffer = ev.buf, desc = 'lsp - show signature info (floating window)' })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,
          { buffer = ev.buf, desc = 'lsp - rename symbol under cursor' })
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action,
          { buffer = ev.buf, desc = 'code-action - run code action' })

        --- Workspace mappings.
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder,
          { buffer = ev.buf, desc = 'lsp - add workspace folder' })
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder,
          { buffer = ev.buf, desc = 'lsp - remove workspace folder' })
        vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
          { buffer = ev.buf, desc = 'lsp - list workspace folders' })

        local builtin = require('telescope.builtin')

        -- Goto the definition of the word under the cursor.
        -- This is where a variable was first declared, or where a function is defined, and etc.
        -- To jump back press <C-T>.
        vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'lsp - goto definitions' })

        -- This is not Goto Definition, this is Goto Declaration.
        -- For example, in C this would take you to the header.
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
          { buffer = ev.buf, desc = 'lsp - goto declaration (e.g. a header in C)' })

        -- Find references for the word under the cursor.
        vim.keymap.set('n', '<leader>lr', builtin.lsp_references, { desc = 'lsp - goto references' })

        -- Goto the implementation of the word under the cursor.
        -- Useful when your language has ways of declaring types without an actual implementation.
        vim.keymap.set('n', '<leader>li', builtin.lsp_implementations, { desc = 'lsp - goto implementation' })

        -- Goto the type of the word under the cursor.
        -- Useful when you are not sure what type a variable is and you want to see the definition of its *type*, not where it was defined.
        vim.keymap.set('n', '<leader>lt', builtin.lsp_type_definitions, { desc = 'lsp - goto type definition' })

        -- Fuzzy find all the symbols in your current document.
        -- Symbols are things like variables, functions, types, etc.
        vim.keymap.set('n', '<leader>ld', builtin.lsp_document_symbols, { desc = 'lsp - fuzzy find document symbols' })

        -- Fuzzy find all the symbols in your current workspace.
        -- Similar to document symbols, but searches over the entire workspace.
        vim.keymap.set('n', '<leader>lw', builtin.lsp_workspace_symbols, { desc = 'lsp - fuzzy find workspace symbols' })
      end,
    })
  end
}
