# FZF configuration

if (( $+commands[fzf] )); then
    # Use fd for file/directory listing if available
    if (( $+commands[fd] )); then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    # Preview with bat if available
    if (( $+commands[bat] )); then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
    fi

    export FZF_DEFAULT_OPTS='
        --height=40%
        --layout=reverse
        --border
        --info=inline
    '

    # Source fzf shell integration (keybindings + completion)
    eval "$(fzf --zsh)" 2>/dev/null
fi
