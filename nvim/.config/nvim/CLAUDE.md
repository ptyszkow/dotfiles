# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration focused on multi-language development with primary support for Python, C#/.NET, and Lua. The configuration uses lazy.nvim for plugin management and is structured for extensibility and maintainability.

## Architecture

### Core Structure

- `init.lua` - Main entry point containing vim options, LSP setup, and diagnostic configuration
- `lua/config/` - Core configuration modules (lazy, dap, terminal)
- `lua/plugins/` - Individual plugin specifications loaded automatically by lazy.nvim

### Key Design Patterns

**Plugin Loading**: Each plugin is defined in its own file under `lua/plugins/`. Lazy.nvim automatically imports all files from this directory (specified in `lua/config/lazy.lua` with `{ import = "plugins" }`).

**Debugging Architecture**: DAP (Debug Adapter Protocol) configuration is centralized in `lua/config/dap.lua` with language-specific adapters:
- Python debugger uses debugpy with automatic venv detection (checks `.venv/` then `venv/`)
- .NET debugger uses netcoredbg for both launch and attach scenarios

**Task Running**: Uses Overseer for task management with pre-configured .NET templates (build, run, test, watch run, clean). Tasks are defined in `lua/plugins/overseer.lua`.

**Testing Integration**: Neotest is configured with the dotnet adapter for running C# tests. Integration between Overseer and Neotest is important - they serve different but complementary purposes.

### Language Server Configuration

LSP servers are enabled in `init.lua:33` via `vim.lsp.enable({ "lua_ls", "csharp_ls", "pyright" })`. Mason automatically ensures `lua_ls` is installed via `lua/plugins/mason-lspconfig.lua`.

## Development Commands

### Reloading Configuration

When modifying Neovim configuration:
```vim
:update | :source
```
Or use keymap: `<leader>ui` (defined in init.lua:27)

### Formatting

Format current buffer: `<leader>lf` or `<leader>cf` (via conform.nvim)

Configured formatters (lua/plugins/conform.lua):
- Lua: stylua
- Python: isort, black
- SQL: sqlformat
- JSON: jq
- HTML: tidy
- Nix: alejandra

### Testing (Neotest)

- `<leader>trn` - Run nearest test
- `<leader>tr` - Run all tests in current file
- `<leader>ts` - Toggle test summary panel
- `<leader>tw` - Toggle test watch mode
- `<leader>tt` - Toggle test output panel
- `<leader>tc` - Clear test output

### Running Tasks (Overseer)

For .NET projects:
- `<leader>rb` - Build project (`dotnet build`)
- `<leader>rr` - Run project (`dotnet run`)
- `<leader>rt` - Test project (`dotnet test`)
- `<leader>rw` - Watch run (`dotnet watch run`)
- `<leader>rc` - Clean project (`dotnet clean`)
- `<leader>ro` - Toggle Overseer task list
- `<leader>rT` - Select and run any task template
- `<leader>rA` - Run action on a task

### Debugging (DAP)

Standard keybindings (lua/config/dap.lua):
- `F5` - Continue/Start debugging
- `F10` - Step over
- `F11` - Step into
- `F12` - Step out
- `<leader>b` - Toggle breakpoint
- `<leader>B` - Set conditional breakpoint

DAP UI automatically opens when debugging starts and closes when debugging ends.

### File Navigation

- `<leader>o` - Open Oil.nvim (file browser that lets you edit directories like buffers)

## Special Configuration Notes

### Python Environment

Python host program is explicitly set in init.lua:57 to `/home/peter/venv/bin/python`. DAP configuration will prefer project-local venvs when debugging.

### Database Connections

Dbee plugin is configured for database interaction. Connection configuration is stored separately (see notes.md for examples using SQL Server and MySQL).

### Clean State / Cache Reset

If experiencing plugin issues, clean Neovim state:
```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```
Then restart Neovim to reinstall plugins.

### Markdown Preview Setup

After first install:
```vim
:Lazy load markdown-preview.nvim
:call mkdp#util#install()
```

## Editor Behavior

- Leader key: Space
- Local leader: Backslash
- Line numbers: Enabled with relative numbering
- Tab width: 2 spaces
- Clipboard: Shared with system (unnamedplus)
- Splits: Open below and to the right
- Case-sensitive search: Smart (case-insensitive unless uppercase is used)

## Plugin Ecosystem

Notable plugins and their purposes:
- **blink.cmp**: Fast completion engine with Rust fuzzy matching, built using Nix
- **codecompanion**: AI coding assistant using Claude Sonnet 4 via Copilot provider
- **conform.nvim**: Formatting with language-specific formatters
- **noice.nvim**: Enhanced UI for messages and command line
- **snacks.nvim**: Collection of small utilities
- **trouble.nvim**: Pretty diagnostics and quickfix list
- **which-key.nvim**: Keymap hints and documentation
- **oil.nvim**: Directory editing as buffers

## Important Constraints

When modifying this configuration:
1. Keep plugin files in `lua/plugins/` - they're auto-loaded
2. Maintain the separation between config modules and plugins
3. DAP configurations should check for virtual environments
4. Overseer templates should include `condition.filetype` for language-specific tasks
5. Keymap descriptions are important for which-key discoverability
