-- ~/.config/nvim/lua/plugins/telescope.lua

return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>",                            desc = "Find files" },
    { "<leader>fa", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", desc = "Find all files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",                             desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                               desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",                             desc = "Help tags" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        layout_config = {
          horizontal = { preview_width = 0.6 },
        },
        file_ignore_patterns = { "%.git/", "node_modules/", "%.cache/" },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    })
  end,
}
