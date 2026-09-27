# ~/.bashrc

# Only for interactive shells.
[[ $- != *i* ]] && return

# Environment
export EDITOR=helix
export VISUAL=helix
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
export PATH="$HOME/.grok/bin:$PATH"

# Private secrets (see .env.example)
[[ -f ~/.env ]] && source ~/.env

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias hx='helix'
alias rone='rclone mount onedrive: OneDrive --vfs-cache-mode full --daemon'
alias rdev='distrobox enter fedora'

# dev-ai container (podman)
alias sai='podman container start dev-ai'
alias cbash='podman exec -itu dev dev-ai bash'
alias cgrok='podman exec -itu dev dev-ai grok'
alias ccodex='podman exec -itu dev dev-ai codex'
alias cclaude='podman exec -itu dev dev-ai claude'

# Open a shell in dev-ai. ~/Projects is mounted at /home/dev/Projects, so when
# inside it, start in the matching directory.
rai() {
  local dir="/home/dev/Projects"
  if [[ "$PWD" == "$HOME"/Projects || "$PWD" == "$HOME"/Projects/* ]]; then
    dir="/home/dev${PWD#"$HOME"}"
  fi
  sai && podman exec -itu dev -w "$dir" dev-ai bash
}

# Completions and prompt
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
eval "$(starship init bash)"
