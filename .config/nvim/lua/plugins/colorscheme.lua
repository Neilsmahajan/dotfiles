-- ~/.config/nvim/lua/plugins/colorscheme.lua

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "auto", -- latte, frappe, macchiato, mocha
      background = {    -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      integrations = {
        cmp = true,
        telescope = true,
        treesitter = true,
      },
    })
    vim.cmd.colorscheme "catppuccin"
  end,
}
