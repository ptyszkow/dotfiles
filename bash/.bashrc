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
# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
# <<< grok installer <<<
alias rai="podman exec -itu dev dev-ai bash"

fastfetch
