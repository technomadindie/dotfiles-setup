# Load all config modules in order
for conf in "$ZDOTDIR"/conf.d/[0-9]*.zsh(N); do
    source "$conf"
done

# Initialize zoxide directory jumping after completion setup
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# Initialize Starship prompt
eval "$(starship init zsh)"
