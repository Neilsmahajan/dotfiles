-- ~/.config/nvim/lua/plugins/lsp.lua

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "b0o/schemastore.nvim" -- for JSON schemas
  },
  config = function()
    -- Configure diagnostics globally
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Helper function for common on_attach
    local on_attach = function(client, bufnr)
      -- Disable formatting for servers where we use conform.nvim
      if client.name == "ts_ls" or client.name == "pyright" or client.name == "gopls" or client.name == "svelte" then
        client.server_capabilities.documentFormattingProvider = false
      end

      -- Enable inlay hints if available
      if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end

    -- Basic servers with minimal config
    local basic_servers = { "lua_ls", "bashls" }
    for _, server in ipairs(basic_servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end

    -- TypeScript/JavaScript
    lspconfig.ts_ls.setup({
      cmd = { "typescript-language-server", "--stdio" },
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          },
        },
      },
    })

    -- Python
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            typeCheckingMode = "basic",
          },
        },
      },
    })

    -- Go
    lspconfig.gopls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          gofumpt = true,
          usePlaceholders = true,
          completeUnimported = true,
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
    })

    -- C/C++ (excluding Arduino)
    lspconfig.clangd.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        -- Clangd specific keymap
        vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>",
          { buffer = bufnr, desc = "Switch Source/Header" })
      end,
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
      filetypes = { "c", "cpp", "objc", "objcpp" },
      root_dir = function(fname)
        -- Don't attach to Arduino files
        if fname:match("%.ino$") then return nil end
        -- More permissive root detection - fallback to current directory
        return require("lspconfig.util").root_pattern(
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          ".git"
        )(fname) or vim.fn.getcwd()
      end,
    })

    -- JSON with schemas
    lspconfig.jsonls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    -- HTML
    lspconfig.html.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html" },
    })

    -- CSS
    lspconfig.cssls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "css", "scss", "less" },
    })

    -- Svelte
    lspconfig.svelte.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "svelte" },
    })

    -- SQL (PostgreSQL)
    -- Requires the Postgres Language Server (postgrestools) installed and on PATH
    -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#postgres_lsp
    lspconfig.postgres_lsp.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "sql" },
      -- Uses default cmd: { "postgrestools", "lsp-proxy" }
    })
  end,
}
