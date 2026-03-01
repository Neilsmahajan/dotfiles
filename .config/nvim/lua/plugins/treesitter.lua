-- ~/.config/nvim/lua/plugins/treesitter.lua
-- Uses Neovim 0.11+ built-in treesitter highlight/indent.
-- nvim-treesitter plugin is kept only for parser management (TSInstall/TSUpdate).

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- Install parsers if missing via the async install API
    local desired_parsers = {
      "lua", "vim", "vimdoc", "bash",
      "python", "javascript", "typescript", "tsx", "json", "html", "css",
      "go", "c", "cpp", "arduino", "svelte",
    }

    local installed = require("nvim-treesitter.config").get_installed()
    local missing = vim.tbl_filter(function(lang)
      return not vim.list_contains(installed, lang)
    end, desired_parsers)

    if #missing > 0 then
      require("nvim-treesitter.install").install(missing, { summary = true })
    end
  end,
}
