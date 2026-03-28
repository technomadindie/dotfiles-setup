#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
OS="$(uname -s)"

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ─── Pre-flight ───────────────────────────────────────────────────────────────

preflight() {
    for cmd in git curl; do
        if ! command -v "$cmd" &>/dev/null; then
            err "$cmd is required but not found. Install it first:"
            if [[ "$OS" == "Linux" ]]; then
                err "  sudo apt install $cmd   (Debian/Ubuntu)"
                err "  sudo dnf install $cmd   (Fedora/RHEL)"
            else
                err "  xcode-select --install  (macOS)"
            fi
            exit 1
        fi
    done
    ok "Pre-flight checks passed (git, curl found)"
}

# ─── Backup existing configs ─────────────────────────────────────────────────

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        warn "Backed up $target → $BACKUP_DIR/"
    fi
}

backup() {
    info "Backing up existing configs..."
    backup_if_exists "$HOME/.zshenv"
    backup_if_exists "$HOME/.zshrc"
    backup_if_exists "$HOME/.gitconfig"
    backup_if_exists "$HOME/.tmux.conf"
    backup_if_exists "$HOME/.config/nvim"
    backup_if_exists "$HOME/.config/starship.toml"
    backup_if_exists "$HOME/.config/bat"
    backup_if_exists "$HOME/.config/ripgrep"
    backup_if_exists "$HOME/.config/fd"
    backup_if_exists "$HOME/.config/zsh"
    ok "Backup complete"
}

# ─── Install packages ────────────────────────────────────────────────────────

install_packages() {
    if [[ "$OS" == "Darwin" ]]; then
        info "Detected macOS"

        # Install Homebrew if missing
        if ! command -v brew &>/dev/null; then
            info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        # Apple Silicon: /opt/homebrew; Intel Mac: /usr/local (see https://docs.brew.sh/Installation)
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        info "Installing packages via Homebrew..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"

    elif [[ "$OS" == "Linux" ]]; then
        info "Detected Linux"

        if command -v apt &>/dev/null; then
            info "Installing packages via apt..."
            sudo apt update
            sudo apt install -y \
                zsh stow ripgrep bat tmux unzip \
                nodejs npm curl git xclip wl-clipboard

            # eza: only when packaged in your release (e.g. Ubuntu 24.04+ universe); skip otherwise
            if apt-cache show eza &>/dev/null; then
                sudo apt install -y eza
            else
                info "eza not in default apt repos for this release; ls aliases fall back to standard ls"
            fi

            # fd-find has a different package name on Debian/Ubuntu
            sudo apt install -y fd-find || true

            # bat binary is 'batcat' on Debian/Ubuntu — symlink to ~/.local/bin
            if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
                ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
            fi

            # fd binary is 'fdfind' on Debian/Ubuntu — symlink to ~/.local/bin
            if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
                ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
            fi

        elif command -v dnf &>/dev/null; then
            info "Installing packages via dnf..."
            sudo dnf install -y \
                zsh stow ripgrep fd-find bat eza tmux unzip \
                nodejs npm curl git xclip wl-clipboard

        else
            err "Unsupported package manager. Install packages manually."
            exit 1
        fi

        # ── Rootless binary installs to ~/.local/bin ──────────────────────
        local arch
        arch="$(uname -m)"

        # Neovim (apt/dnf ship outdated versions missing vim.keymap etc.)
        if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -1 | sed 's/[^0-9]*\([0-9]*\)\.\([0-9]*\).*/\1\2/')" -lt "09" ]]; then
            info "Installing Neovim (latest stable) to ~/.local/bin..."
            local nvim_arch
            case "$arch" in
                x86_64)        nvim_arch="x86_64" ;;
                aarch64|arm64) nvim_arch="arm64" ;;
                *)             warn "nvim: unsupported architecture $arch" ;;
            esac
            if [[ -n "${nvim_arch:-}" ]]; then
                local nvim_tmp
                nvim_tmp="$(mktemp -d)"
                curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz" \
                    | tar xz -C "$nvim_tmp"
                cp -r "$nvim_tmp"/nvim-linux-${nvim_arch}/* "$HOME/.local/"
                rm -rf "$nvim_tmp"
                ok "Neovim installed"
            fi
        fi

        # fzf (always install latest to ~/.local/bin to override outdated system versions)
        {
            info "Installing fzf to ~/.local/bin..."
            local fzf_arch
            case "$arch" in
                x86_64)        fzf_arch="amd64" ;;
                aarch64|arm64) fzf_arch="arm64" ;;
                *)             warn "fzf: unsupported architecture $arch" ;;
            esac
            if [[ -n "${fzf_arch:-}" ]]; then
                local fzf_ver
                fzf_ver="$(curl -sS https://api.github.com/repos/junegunn/fzf/releases/latest \
                    | grep '"tag_name"' | head -1 | sed 's/.*"v\(.*\)".*/\1/')"
                curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${fzf_ver}/fzf-${fzf_ver}-linux_${fzf_arch}.tar.gz" \
                    | tar xz -C "$HOME/.local/bin"
                ok "fzf ${fzf_ver} installed"
            fi
        }

        # git-delta
        if ! command -v delta &>/dev/null; then
            info "Installing git-delta to ~/.local/bin..."
            local delta_arch
            case "$arch" in
                x86_64)        delta_arch="x86_64" ;;
                aarch64|arm64) delta_arch="aarch64" ;;
                *)             warn "git-delta: unsupported architecture $arch" ;;
            esac
            if [[ -n "${delta_arch:-}" ]]; then
                local delta_ver delta_tmp
                delta_ver="$(curl -sS https://api.github.com/repos/dandavison/delta/releases/latest \
                    | grep '"tag_name"' | head -1 | sed 's/.*"\(.*\)".*/\1/')"
                delta_tmp="$(mktemp -d)"
                curl -fsSL "https://github.com/dandavison/delta/releases/download/${delta_ver}/delta-${delta_ver}-${delta_arch}-unknown-linux-gnu.tar.gz" \
                    | tar xz -C "$delta_tmp"
                cp "$delta_tmp/delta-${delta_ver}-${delta_arch}-unknown-linux-gnu/delta" "$HOME/.local/bin/"
                rm -rf "$delta_tmp"
                ok "git-delta ${delta_ver} installed"
            fi
        fi

        # Starship
        if ! command -v starship &>/dev/null; then
            info "Installing Starship to ~/.local/bin..."
            curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" --yes
        fi
    fi
    ok "Packages installed"
}

# ─── Install oh-my-zsh ───────────────────────────────────────────────────────

install_omz() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" \
            --unattended --keep-zshrc
        # oh-my-zsh creates ~/.zshrc even with --keep-zshrc; remove it since we use ZDOTDIR
        rm -f "$HOME/.zshrc"
        ok "oh-my-zsh installed"
    else
        ok "oh-my-zsh already installed"
    fi
}

# ─── Clone oh-my-zsh custom plugins ──────────────────────────────────────────

install_omz_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    clone_plugin() {
        local repo="$1"
        local name="$(basename "$repo")"
        local dest="$ZSH_CUSTOM/plugins/$name"

        if [[ ! -d "$dest" ]]; then
            info "Cloning $name..."
            git clone "https://github.com/$repo.git" "$dest"
        else
            ok "$name already installed"
        fi
    }

    clone_plugin "zsh-users/zsh-autosuggestions"
    clone_plugin "zsh-users/zsh-syntax-highlighting"
    clone_plugin "zsh-users/zsh-history-substring-search"
    clone_plugin "zsh-users/zsh-completions"
    clone_plugin "Aloxaf/fzf-tab"
    ok "oh-my-zsh plugins installed"
}

# ─── Clone TPM (Tmux Plugin Manager) ─────────────────────────────────────────

install_tpm() {
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        info "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        ok "TPM installed"
    else
        ok "TPM already installed"
    fi
}

# ─── Install Nerd Font ───────────────────────────────────────────────────────

install_nerd_font() {
    local font_name="Hack"
    local font_zip="${font_name}.zip"
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_zip}"

    if [[ "$OS" == "Darwin" ]]; then
        local font_dir="$HOME/Library/Fonts"
    else
        local font_dir="$HOME/.local/share/fonts"
    fi

    # Check if already installed
    if ls "$font_dir"/HackNerdFont* &>/dev/null 2>&1; then
        ok "Hack Nerd Font already installed"
        return
    fi

    info "Installing Hack Nerd Font..."
    mkdir -p "$font_dir"

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    curl -fsSL "$font_url" -o "$tmp_dir/$font_zip"
    unzip -qo "$tmp_dir/$font_zip" -d "$tmp_dir/font"
    cp "$tmp_dir"/font/*.ttf "$font_dir/"
    rm -rf "$tmp_dir"

    # Rebuild font cache on Linux
    if [[ "$OS" == "Linux" ]] && command -v fc-cache &>/dev/null; then
        fc-cache -f "$font_dir"
    fi

    ok "Hack Nerd Font installed to $font_dir"
}

# ─── Stow all packages ───────────────────────────────────────────────────────

install_stow() {
    info "Creating symlinks with stow..."
    cd "$DOTFILES_DIR"

    # Ensure ~/.config exists
    mkdir -p "$HOME/.config"

    stow_packages=(zsh git starship nvim tmux bat ripgrep fd)
    for pkg in "${stow_packages[@]}"; do
        stow -v -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
        ok "Stowed $pkg"
    done
}

# ─── Create local config template ────────────────────────────────────────────

install_local_conf() {
    local LOCAL_CONF="$HOME/.config/zsh/conf.d/99-local.zsh"
    if [[ ! -f "$LOCAL_CONF" ]]; then
        cat > "$LOCAL_CONF" << 'EOF'
# Machine-specific configuration (gitignored)
# Add your local PATH additions, work-specific aliases, etc. here

EOF
        ok "Created $LOCAL_CONF (edit for machine-specific config)"
    else
        ok "99-local.zsh already exists"
    fi
}

# ─── Set default shell ───────────────────────────────────────────────────────

install_default_shell() {
    local ZSH_PATH
    ZSH_PATH="$(which zsh)"
    if [[ "$SHELL" == "$ZSH_PATH" ]]; then
        ok "zsh is already the default shell"
        return
    fi

    info "Setting zsh as default shell..."

    local current_user
    current_user="$(whoami)"

    # Ensure zsh is listed in /etc/shells (required for chsh to work)
    if ! grep -qx "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi

    # sudo chsh avoids chsh's own interactive password prompt
    if sudo chsh -s "$ZSH_PATH" "$current_user"; then
        ok "Default shell set to zsh (log out and back in for it to take effect)"
    else
        warn "Could not set default shell automatically."
        warn "Run manually: sudo chsh -s $ZSH_PATH $current_user"
    fi
}

# ─── Summary ─────────────────────────────────────────────────────────────────

summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Dotfiles installation complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo ""
    echo "  Configs backed up to: $BACKUP_DIR"
    echo "  Dotfiles directory:   $DOTFILES_DIR"
    echo ""
    echo "  Next steps:"
    echo "    1. Log out and back in for the default shell change to take effect"
    echo "    2. In tmux, press prefix + I to install tmux plugins"
    echo "    3. Open nvim — plugins will auto-install on first launch"
    echo "    4. Edit ~/.config/zsh/conf.d/99-local.zsh for machine-specific config"
    echo ""
}

# ─── Skip helper ─────────────────────────────────────────────────────────────

# Populated from --skip=a,b,c flag
SKIP_STEPS=()

should_skip() {
    local step="$1"
    for s in "${SKIP_STEPS[@]}"; do
        [[ "$s" == "$step" ]] && return 0
    done
    return 1
}

run_step() {
    local name="$1"; shift
    if should_skip "$name"; then
        warn "Skipping: $name"
    else
        "$@"
    fi
}

# ─── Run all steps (full install) ────────────────────────────────────────────

install_all() {
    preflight
    run_step backup          backup
    run_step packages        install_packages
    run_step omz             install_omz
    run_step omz-plugins     install_omz_plugins
    run_step tpm             install_tpm
    run_step nerd-font       install_nerd_font
    run_step stow            install_stow
    run_step local-conf      install_local_conf
    run_step default-shell   install_default_shell
    summary
}

# ─── Help ─────────────────────────────────────────────────────────────────────

show_help() {
    echo "Usage: ./install.sh [command] [--skip=step1,step2,...]"
    echo ""
    echo "Commands:"
    echo "  (no args)       Run full installation"
    echo "  packages        Install brew/apt/dnf packages"
    echo "  omz             Install oh-my-zsh"
    echo "  omz-plugins     Clone oh-my-zsh custom plugins"
    echo "  tpm             Install Tmux Plugin Manager"
    echo "  nerd-font       Install Hack Nerd Font"
    echo "  stow            Create symlinks with GNU Stow"
    echo "  local-conf      Create 99-local.zsh template"
    echo "  default-shell   Set zsh as default shell"
    echo "  backup          Backup existing configs"
    echo "  help            Show this help"
    echo ""
    echo "Options:"
    echo "  --skip=a,b,...  Skip one or more steps during full install"
    echo ""
    echo "Examples:"
    echo "  ./install.sh --skip=default-shell"
    echo "  ./install.sh --skip=nerd-font,omz-plugins"
}

# ─── Dispatcher ───────────────────────────────────────────────────────────────

# Parse --skip=a,b,c from any position in args
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == --skip=* ]]; then
        IFS=',' read -ra SKIP_STEPS <<< "${arg#--skip=}"
    else
        ARGS+=("$arg")
    fi
done
set -- "${ARGS[@]}"

case "${1:-all}" in
    all)            install_all ;;
    packages)       preflight && install_packages ;;
    omz)            preflight && install_omz ;;
    omz-plugins)    preflight && install_omz_plugins ;;
    tpm)            preflight && install_tpm ;;
    nerd-font)      preflight && install_nerd_font ;;
    stow)           install_stow ;;
    local-conf)     install_local_conf ;;
    default-shell)  install_default_shell ;;
    backup)         backup ;;
    help|--help|-h) show_help ;;
    *)              err "Unknown command: $1" && show_help && exit 1 ;;
esac
