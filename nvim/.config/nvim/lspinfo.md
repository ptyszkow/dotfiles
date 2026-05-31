# LSP Keybindings Reference

## Mnemonic Groups

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `g` | **G**o to a location | `gd` definition, `gD` declaration, `gr` references |
| `<leader>c` | **C**ode actions/refactoring | `ca` action, `cr` rename, `cf` format |
| `<leader>s` | **S**earch/symbols (pickers) | `ss` symbols, `sS` workspace symbols |
| `<leader>x` | Diagnostics (Trouble) | `xx` all, `xX` buffer |
| `[` / `]` | Previous / Next | `[d` / `]d` diagnostics |

## Navigation (g = Go to)

| Mapping | Action | Source |
|---------|--------|--------|
| `gd` | **G**o to **D**efinition | snacks picker |
| `gD` | **G**o to **D**eclaration | snacks picker |
| `gr` | **G**o to **R**eferences | snacks picker |
| `gI` | **G**o to **I**mplementation | snacks picker |
| `gy` | **G**o to T**y**pe Definition | snacks picker |
| `gO` | Document symbols (outline) | nvim default |

## Code Actions (<leader>c = Code)

| Mapping | Action | Mode | Source |
|---------|--------|------|--------|
| `<leader>ca` | **C**ode **A**ction | normal + visual | init.lua |
| `<leader>cr` | **C**ode **R**ename | normal | init.lua |
| `<leader>cf` | **C**ode **F**ormat | normal | conform.nvim |
| `<leader>ch` | **C**ode inlay **H**ints toggle | normal | init.lua |
| `<leader>cL` | **C**ode **L**ens run | normal | init.lua |
| `<leader>cl` | **C**ode **L**SP panel (Trouble) | normal | trouble.nvim |
| `<leader>cs` | **C**ode **S**ymbols (Trouble) | normal | trouble.nvim |

## Search / Symbols (<leader>s = Search)

| Mapping | Action | Source |
|---------|--------|--------|
| `<leader>ss` | **S**earch **S**ymbols (document) | snacks picker |
| `<leader>sS` | **S**earch **S**ymbols (workspace) | snacks picker |
| `<leader>sd` | **S**earch **D**iagnostics (all) | snacks picker |
| `<leader>sD` | **S**earch **D**iagnostics (buffer) | snacks picker |

## Diagnostics

| Mapping | Action | Source |
|---------|--------|--------|
| `[d` | Previous diagnostic | nvim default |
| `]d` | Next diagnostic | nvim default |
| `[D` | First diagnostic in buffer | nvim default |
| `]D` | Last diagnostic in buffer | nvim default |
| `<C-W>d` | Diagnostic float under cursor | nvim default |
| `<leader>xx` | Diagnostics list (Trouble) | trouble.nvim |
| `<leader>xX` | Buffer diagnostics (Trouble) | trouble.nvim |

## Hover / Signature

| Mapping | Action | Source |
|---------|--------|--------|
| `K` | Hover documentation | nvim default |
| `<C-S>` | Signature help (insert mode) | nvim default |

## Changes Made

- Removed `<leader>lf` (was duplicate of `<leader>cf` from conform.nvim)
- Added visual mode to `<leader>ca` (needed for extract method/variable)
- Added `<leader>ch` for toggling inlay hints (**C**ode **H**ints)
- Added `<leader>cL` for running codelens (**C**ode **L**ens, capital L since `cl` is Trouble)
