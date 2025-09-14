-- ~/.config/nvim/lua/plugins/format.lua

return {
  "stevearc/conform.nvim",
  config = function()
    local conform = require("conform")

    -- Custom clang-format configuration
    local clang_format_config = vim.fn.stdpath("config") .. "/.clang-format"

    conform.setup({
      formatters_by_ft = {
        python = { "isort", "black" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        arduino = { "clang-format" },
        svelte = { "prettier" },
        sql = { "pg_format", "sql-formatter" },
      },
      formatters = {
        ["clang-format"] = {
          args = { "--style=file:" .. clang_format_config },
        },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end,
}
