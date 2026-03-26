# oh-my-zsh configuration

export ZSH="$HOME/.oh-my-zsh"

# Update settings
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14

# Plugins (custom ones cloned into $ZSH_CUSTOM/plugins/ by install.sh)
# Order matters: completions first, syntax-highlighting near last, history-substring-search last
plugins=(
    zsh-completions
    extract
    z
    fzf-tab
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
)

# Plugin configuration (set before sourcing oh-my-zsh)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# fzf-tab configuration
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no

source "$ZSH/oh-my-zsh.sh"
