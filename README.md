# dotfiles

Personal Linux desktop config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a Stow package that mirrors `$HOME`.

| Package   | What it configures                                                    |
| --------- | --------------------------------------------------------------------- |
| `bash`    | `~/.bashrc`: aliases, PATH, starship prompt, `dev-ai` container helpers |
| `niri`    | [niri](https://github.com/YaLTeR/niri) compositor: outputs, layout, keybinds |
| `wezterm` | WezTerm: Tokyo Night theme, per-tab wallpapers, colored tabs          |
| `yazi`    | yazi file manager: Noctalia flavor, `split-tabs` plugin               |

## Install

```sh
git clone <repo> ~/Projects/dotfiles
cd ~/Projects/dotfiles
stow --target="$HOME" --restow bash niri wezterm yazi
cp bash/.env.example ~/.env   # then fill in real values
```

## Notes

- **Secrets** live in `~/.env` (git-ignored) and are sourced by `.bashrc`.
- **Generated files**: `niri/.config/niri/noctalia.kdl` and the yazi Noctalia
  flavor are written by [Noctalia](https://github.com/noctalia-dev/noctalia-shell)
  from its color scheme, so don't edit them by hand.
- **Vendored plugin**: `yazi/.../plugins/split-tabs.yazi` is managed by
  `ya pkg` (pinned in `package.toml`). Update with `ya pkg upgrade`.

## WezTerm keys

Leader is `Ctrl+T`.

| Keys                       | Action                                   |
| -------------------------- | ---------------------------------------- |
| `Ctrl+Shift+H/J/K/L`       | Focus pane                               |
| `Ctrl+Shift+D` / `S`       | Split vertical / horizontal              |
| `Ctrl+Shift+Q`             | Close pane                               |
| `Ctrl+Shift+T`             | New tab (then `c` to pick its color)     |
| `Ctrl+Shift+A`             | Run `rai` (dev-ai shell)                 |
| `Leader r`                 | Rename tab                               |
| `Leader 0-9` / `n` / `x`   | Set tab color / random / clear           |
| `Leader c`, then a letter  | Set tab color by letter (`r g b v y o c p w m`) |
| `Leader l`                 | Launcher                                 |
