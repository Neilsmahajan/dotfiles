-- ~/.config/nvim/lua/config/options.lua

local opt = vim.opt

-- Editor appearance
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"

-- Editor behavior
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.cindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Arduino filetype detection
vim.filetype.add({
  extension = {
    ino = "arduino",
  },
})

-- Better TSX/JSX filetype detection
vim.filetype.add({
  extension = {
    tsx = "typescriptreact",
    jsx = "javascriptreact",
  },
})

-- Language-specific indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { 
    "javascript", "javascriptreact", "typescript", "typescriptreact", 
    "json", "html", "css", "lua"
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.cindent = true
    vim.opt_local.smartindent = true
    -- Ensure proper indentation in insert mode
    vim.opt_local.indentexpr = "nvim_treesitter#indent()"
  end,
})
