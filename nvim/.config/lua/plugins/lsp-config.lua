return {
  -- Mason base
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = { auto_install = true },
  },

  -- NONE-LS (antes null-ls) para RuboCop/ERB
  {
    "nvimtools/none-ls.nvim",
    lazy = false,
    config = function()
      local null_ls = require("null-ls")

      local sources = {
        -- Ruby
        null_ls.builtins.formatting.rubocop.with({
          command = "bundle",
          args = { "exec", "rubocop", "--fix-layout", "--stdin", "$FILENAME" },
        }),
        null_ls.builtins.diagnostics.rubocop.with({
          command = "bundle",
          args = { "exec", "rubocop", "--force-exclusion", "--format", "json", "--stdin", "$FILENAME" },
        }),
        -- ERB (elige la que uses en tu proyecto)
        -- null_ls.builtins.formatting.erb_format, -- requiere gem 'erb_format'
        -- o si usas 'erb-formatter':
        -- null_ls.builtins.formatting.erb_lint.with({ command = "erb-formatter" }),
      }

      null_ls.setup({ sources = sources })

      -- Formato al guardar para Ruby/ERB/HTML/CSS/JS
      local grp = vim.api.nvim_create_augroup("FmtOnSave", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = grp,
        pattern = { "*.rb", "*.erb", "*.rake", "Gemfile", "Capfile", "*.html", "*.css", "*.js", "*.jsx", "*.ts", "*.tsx" },
        callback = function() vim.lsp.buf.format({ async = false }) end,
      })
    end,
  },

  -- LSPCONFIG
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      -- 🟥 Ruby on Rails: ruby-lsp (NO solargraph)
      -- Asegúrate de tener ruby-lsp en tu Gemfile (development) o instalado.
      lspconfig.ruby_lsp.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- ruby-lsp ya da formatting via RuboCop si lo detecta
        end,
      })

      -- CSS
      lspconfig.cssls.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = true
          client.server_capabilities.documentRangeFormattingProvider = true
        end,
      })

      -- Emmet (incluye ERB)
      lspconfig.emmet_ls.setup({
        capabilities = capabilities,
        filetypes = {
          "css", "eruby", "html", "javascript", "javascriptreact",
          "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue",
        },
        init_options = { html = { options = { ["bem.enabled"] = true } } },
      })

      -- TS/JS
      lspconfig.ts_ls.setup({ capabilities = capabilities })

      -- HTML
      lspconfig.html.setup({ capabilities = capabilities })

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Keymaps LSP
      local map = vim.keymap.set
      map("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
      map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
      map("n", "<leader>gr", vim.lsp.buf.references, { desc = "References" })
      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
      map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
      map("n", "<leader>fd", function() vim.diagnostic.open_float(nil, { focus = false }) end, { desc = "Line Diagnostics" })
    end,
  },

  -- RECOMENDADOS para Rails (añádelos a tu setup de plugins)
  { "tpope/vim-rails" },                   -- navegación Rails
  { "nvim-treesitter/nvim-treesitter", build=":TSUpdate" }, -- syntax (ruby, eruby)
}

