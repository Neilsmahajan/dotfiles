# Simplified Neovim Configuration

A clean and minimal Neovim configuration focused on essential development tools.

## Features

- **LSP Support**: Python, TypeScript/JavaScript, Go, C/C++, Lua, and more
- **Arduino Development**: Complete Arduino CLI integration with `<leader>av` (compile) and `<leader>au` (upload)
- **Code Formatting**: Automatic formatting with conform.nvim
- **File Navigation**: Telescope for fuzzy finding
- **Autocompletion**: nvim-cmp with LSP integration
- **Syntax Highlighting**: Treesitter for modern syntax highlighting
- **Theme**: Catppuccin color scheme

## Key Bindings

### General

- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - List buffers
- `<leader>cf` - Format buffer
- `<leader>e` - Show diagnostics

### Arduino (in .ino files)

- `<leader>av` - Compile Arduino code
- `<leader>au` - Upload to Arduino
- `<leader>as` - Open serial monitor

### TypeScript/JavaScript

- `<leader>to` - Organize imports
- `<leader>ti` - Add missing imports
- `<leader>tu` - Remove unused imports

### Go

- `<leader>gt` - Run Go tests
- `<leader>gc` - Show Go coverage

## Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration entry
├── lua/
│   ├── config/
│   │   ├── options.lua         # Editor options
│   │   └── keymaps.lua         # Key mappings
│   └── plugins/
│       ├── arduino.lua         # Arduino development
│       ├── colorscheme.lua     # Theme configuration
│       ├── cmp.lua            # Autocompletion
│       ├── essentials.lua     # Basic plugins (autopairs, comments, etc.)
│       ├── format.lua         # Code formatting
│       ├── go.lua             # Go development
│       ├── lsp.lua            # Language servers
│       ├── snippets.lua       # Code snippets
│       ├── telescope.lua      # File finder
│       ├── treesitter.lua     # Syntax highlighting
│       └── typescript.lua     # TypeScript tools
└── .clang-format              # C/C++/Arduino formatting config
```

## Installation

1. Backup your existing config: `mv ~/.config/nvim ~/.config/nvim.backup`
2. Install this config
3. Open Neovim and run `:Lazy` to install plugins
4. Install language servers as needed
