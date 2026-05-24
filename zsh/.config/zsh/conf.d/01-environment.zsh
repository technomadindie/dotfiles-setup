# Environment, PATH, and history configuration

# OS detection
export DOTFILES_OS="$(uname -s)"

# Deduplicate PATH
typeset -U path

# Cross-platform PATH setup
path=(
    "$HOME/.local/bin"
    "$HOME/bin"
    $path
)

if [[ "$DOTFILES_OS" == "Darwin" ]]; then
    path=("/opt/homebrew/bin" "/opt/homebrew/sbin" $path)
fi

# History
HISTFILE="$HOME/.zhistory"
HISTSIZE=100000
SAVEHIST=100000

setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# Locale
if [[ -n "${DOTFILES_LOCALE:-}" ]]; then
    export LANG="$DOTFILES_LOCALE"
    export LC_ALL="$DOTFILES_LOCALE"
fi

# Pager
export PAGER="less"
if (( $+commands[bat] )); then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
