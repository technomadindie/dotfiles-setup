# Keybindings

# Emacs mode
bindkey -e
export KEYTIMEOUT=1

# History substring search (up/down arrows)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Home / End / Delete (works across terminal emulators)
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line

# Backspace fix
bindkey "^?" backward-delete-char

# Edit command in $EDITOR with Ctrl-X Ctrl-E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
