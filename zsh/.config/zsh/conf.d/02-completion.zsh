# Completion configuration (runs after oh-my-zsh compinit)

# Additional completion options
comp_options+=(globdots)
zstyle ':completion:*' file-sort access
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Shell options
setopt CORRECT
setopt BANG_HIST
setopt ALIASES
setopt MARK_DIRS
setopt AUTO_PARAM_SLASH
setopt autocd notify

# Auto-Pushd
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Recent directories
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-file "${ZDOTDIR:-$HOME/.config/zsh}/.chpwd-recent-dirs"

# Directory stack navigation
alias d='dirs -v'
for index ({1..20}) alias "$index"="cd +${index}"; unset index
