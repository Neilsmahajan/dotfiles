-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua", "vim", "vimdoc", "bash",
        "python", "javascript", "typescript", "tsx", "json", "html", "css",
        "go", "c", "cpp", "arduino", "svelte"
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
