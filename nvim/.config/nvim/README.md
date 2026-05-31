# Neovim Configuration

## Language Servers

### Auto-installed by Mason

The following LSP servers are installed automatically on startup via Mason:

- `lua_ls` — Lua
- `csharp_ls` — C# / .NET (requires `dotnet` SDK)
- `jsonls` — JSON (requires `npm`)
- `yamlls` — YAML (requires `npm`)
- `html` — HTML (requires `npm`)
- `ts_ls` — JavaScript / TypeScript (requires `npm`)

#### Prerequisites

**.NET SDK** (for `csharp_ls`):
```bash
sudo apt install dotnet-sdk-8.0
```

**Node.js / npm** (for `jsonls`, `yamlls`, `html`, `ts_ls`):

Install Node.js via [nvm](https://github.com/nvm-sh/nvm) (downloads directly from nodejs.org, not npm registry):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc  # or ~/.zshrc if using zsh
nvm install --lts
```

### Manually installed

#### basedpyright (Python)

Uses [uv](https://github.com/astral-sh/uv) instead of pip.

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.local/bin/env  # or restart your shell

# Install basedpyright
uv tool install basedpyright
```

> All manually installed servers are enabled via `vim.lsp.enable()` in `init.lua` and will be picked up automatically as long as their binaries are on your PATH.
