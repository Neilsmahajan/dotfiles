-- ~/.config/nvim/lua/config/keymaps.lua

local map = vim.keymap.set

-- Basic
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear highlights" })

-- Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
-- Removed <C-l> to avoid conflict with Copilot in insert mode

-- Better page movement
map("n", "<C-d>", "<C-d>zz", { desc = "Page down & center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Page up & center" })

-- Insert mode
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP info" })
map("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "LSP restart" })

-- File explorer
map("n", "<leader>fe", "<cmd>Ex<cr>", { desc = "File explorer" })

-- Neo-tree (file explorer plugin) keymaps
map("n", "<leader>nt", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neo-tree file explorer" })
map("n", "<leader>nr", "<cmd>Neotree reveal<cr>", { desc = "Reveal current file in Neo-tree" })
map("n", "<leader>nf", "<cmd>Neotree float<cr>", { desc = "Neo-tree floating window" })

-- Formatting
map("n", "<leader>cf", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format buffer" })

-- Lazygit
map("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Language-specific keymaps
-- Arduino
vim.api.nvim_create_autocmd("FileType", {
  pattern = "arduino",
  callback = function()
    local opts = { buffer = true }
    map("n", "<leader>av", "<cmd>ArduinoCompile<cr>", vim.tbl_extend("force", opts, { desc = "Arduino compile" }))
    map("n", "<leader>au", "<cmd>ArduinoUpload<cr>", vim.tbl_extend("force", opts, { desc = "Arduino upload" }))
    map("n", "<leader>as", "<cmd>ArduinoSerial<cr>", vim.tbl_extend("force", opts, { desc = "Arduino serial" }))
  end,
})

-- TypeScript and JavaScript
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    local opts = { buffer = true }
    map("n", "<leader>to", "<cmd>TSToolsOrganizeImports<cr>",
      vim.tbl_extend("force", opts, { desc = "Organize imports" }))
    map("n", "<leader>ti", "<cmd>TSToolsAddMissingImports<cr>",
      vim.tbl_extend("force", opts, { desc = "Add missing imports" }))
    map("n", "<leader>tu", "<cmd>TSToolsRemoveUnusedImports<cr>",
      vim.tbl_extend("force", opts, { desc = "Remove unused imports" }))
  end,
})

-- Go
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    local opts = { buffer = true }
    map("n", "<leader>gt", "<cmd>GoTest<cr>", vim.tbl_extend("force", opts, { desc = "Run Go tests" }))
    map("n", "<leader>gc", "<cmd>GoCoverage<cr>", vim.tbl_extend("force", opts, { desc = "Go coverage" }))
  end,
})
