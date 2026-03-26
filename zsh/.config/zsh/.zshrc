# Load all config modules in order
for conf in "$ZDOTDIR"/conf.d/[0-9]*.zsh(N); do
    source "$conf"
done

# Initialize Starship prompt
eval "$(starship init zsh)"
