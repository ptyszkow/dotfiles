#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias hx='helix'
alias rone="rclone mount onedrive: OneDrive --vfs-cache-mode full --daemon"
alias rdev="distrobox enter fedora"

#PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"
[[ -f ~/.env ]] && source ~/.env

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"

# <<< grok installer <<<
# export PATH="$(go env GOPATH)/bin:$PATH"
alias sai='podman container start dev-ai'
# ~/Projects is mounted at /home/dev/Projects. Reuse the path relative to ~/.
rai() {
  local dir="/home/dev/Projects"
  if [[ "$PWD" == "$HOME"/Projects || "$PWD" == "$HOME"/Projects/* ]]; then
    dir="/home/dev${PWD#"$HOME"}"
  fi
  sai && podman exec -itu dev -w "$dir" dev-ai bash
}
alias cbash='podman exec -itu dev dev-ai bash'
alias cgrok='podman exec -itu dev dev-ai grok'
alias ccodex='podman exec -itu dev dev-ai codex'
alias cclaude='podman exec -itu dev dev-ai claude'
# fastfetch

export EDITOR=helix
export VISUAL=helix
