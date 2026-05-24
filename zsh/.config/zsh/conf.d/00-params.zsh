# Local dotfiles parameters

DOTFILES_PARAMS_FILE="$HOME/.params_for_dotfiles"
DOTFILES_LEGACY_PARAMS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/params.env"
if [[ -f "$DOTFILES_PARAMS_FILE" ]]; then
    source "$DOTFILES_PARAMS_FILE"
elif [[ -f "$DOTFILES_LEGACY_PARAMS_FILE" ]]; then
    source "$DOTFILES_LEGACY_PARAMS_FILE"
fi
unset DOTFILES_PARAMS_FILE DOTFILES_LEGACY_PARAMS_FILE
