#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rone="rclone mount onedrive: OneDrive --vfs-cache-mode full --daemon"

#PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"
[[ -f ~/.env ]] && source ~/.env

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
# <<< grok installer <<<
alias scai='podman container start dev-ai'
alias rai='podman exec -itu dev dev-ai bash'
alias cbash='podman exec -itu dev dev-ai bash'
alias cgrok='podman exec -itu dev dev-ai grok'
alias ccodex='podman exec -itu dev dev-ai codex'
alias cclaude='podman exec -itu dev dev-ai claude'
fastfetch
