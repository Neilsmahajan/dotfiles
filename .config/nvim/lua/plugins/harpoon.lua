-- ~/.config/nvim/lua/plugins/harpoon.lua

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED: Setup harpoon
    harpoon:setup()

    -- Keymaps
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add file to harpoon" })
    vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = "Toggle harpoon quick menu" })

    -- Select files 1-4
    vim.keymap.set("n", "<leader>j", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
    vim.keymap.set("n", "<leader>k", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
    vim.keymap.set("n", "<leader>l", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
    vim.keymap.set("n", "<leader>;", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

    -- Navigate between harpoon files
    vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Previous harpoon file" })
    vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end, { desc = "Next harpoon file" })
  end,
}
