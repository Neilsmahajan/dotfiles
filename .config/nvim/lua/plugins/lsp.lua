-- ~/.config/nvim/lua/plugins/lsp.lua
-- Uses Neovim 0.11+ native vim.lsp.config / vim.lsp.enable APIs.
-- nvim-lspconfig is kept as a dependency for server config defaults (cmd, filetypes, root_markers).

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "b0o/schemastore.nvim", -- for JSON schemas
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

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Common on_attach behaviour applied via LspAttach autocmd
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        -- Disable formatting for servers where we use conform.nvim
        local no_format = { ts_ls = true, pyright = true, gopls = true, svelte = true }
        if no_format[client.name] then
          client.server_capabilities.documentFormattingProvider = false
        end

        -- Enable inlay hints if available
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end

        -- Clangd specific keymap
        if client.name == "clangd" then
          vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>",
            { buffer = args.buf, desc = "Switch Source/Header" })
        end
      end,
    })

    -- Shared defaults applied to every server
    local shared = {
      capabilities = capabilities,
    }

    ---Helper: merge shared defaults with server-specific overrides
    ---@param overrides? table
    ---@return table
    local function with(overrides)
      return vim.tbl_deep_extend("force", shared, overrides or {})
    end

    -- Basic servers with minimal config
    vim.lsp.config("lua_ls", with())
    vim.lsp.config("bashls", with())

    -- TypeScript/JavaScript
    vim.lsp.config("ts_ls", with({
      cmd = { "typescript-language-server", "--stdio" },
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
    }))

    -- Python
    vim.lsp.config("pyright", with({
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            typeCheckingMode = "basic",
          },
        },
      },
    }))

    -- Go
    vim.lsp.config("gopls", with({
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
    }))

    -- C/C++ (excluding Arduino)
    vim.lsp.config("clangd", with({
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
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname:match("%.ino$") then return end
        local root = require("lspconfig.util").root_pattern(
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          ".git"
        )(fname)
        on_dir(root or vim.fn.getcwd())
      end,
    }))

    -- JSON with schemas
    vim.lsp.config("jsonls", with({
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    }))

    -- HTML
    vim.lsp.config("html", with({
      filetypes = { "html" },
    }))

    -- CSS
    vim.lsp.config("cssls", with({
      filetypes = { "css", "scss", "less" },
    }))

    -- Svelte
    vim.lsp.config("svelte", with({
      filetypes = { "svelte" },
    }))

    -- SQL (PostgreSQL)
    vim.lsp.config("postgres_lsp", with({
      filetypes = { "sql" },
    }))

    -- Enable all configured servers
    vim.lsp.enable({
      "lua_ls",
      "bashls",
      "ts_ls",
      "pyright",
      "gopls",
      "clangd",
      "jsonls",
      "html",
      "cssls",
      "svelte",
      "postgres_lsp",
    })
  end,
}
