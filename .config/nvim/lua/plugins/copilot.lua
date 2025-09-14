-- ~/.config/nvim/lua/plugins/copilot.lua

return {
  "github/copilot.vim",
  config = function()
    -- Disable default mappings
    vim.g.copilot_no_tab_map = true

    -- Set Ctrl+L to accept suggestions
    vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      desc = "Accept Copilot suggestion"
    })

    -- Optional: Set Ctrl+J to accept next word
    vim.keymap.set("i", "<C-j>", "<Plug>(copilot-accept-word)", {
      desc = "Accept Copilot word"
    })
  end,
}
