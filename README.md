# dotfiles-setup

Cross-platform dotfiles for macOS and Linux. Modular zsh config with oh-my-zsh, plus configs for neovim, tmux, git, and modern CLI tools.

## What's Included

| Tool | Config | Description |
|---|---|---|
| **Zsh** | `zsh/` | Modular `conf.d/` layout with oh-my-zsh plugin management |
| **Neovim** | `nvim/` | Minimal setup: lazy.nvim, treesitter, telescope, catppuccin |
| **Tmux** | `tmux/` | C-a prefix, vim-like nav, tmux-power theme, TPM |
| **Git** | `git/` | Delta pager (side-by-side diffs), rebase on pull, useful aliases |
| **Starship** | `starship/` | Compact prompt with git status and language contexts |
| **bat** | `bat/` | Dracula theme, line numbers |
| **ripgrep** | `ripgrep/` | Smart-case, hidden files, sensible ignores |
| **fd** | `fd/` | Ignore .git, node_modules, .cache |

## Architecture

```
~/dotfiles/                     ← This repo
├── install.sh                  ← Bootstrap script with subcommands
├── Brewfile                    ← Homebrew packages (macOS)
│
├── zsh/                        ← Stow package → symlinks into ~/
│   ├── .zshenv                 ← Sets XDG dirs, ZDOTDIR, EDITOR
│   └── .config/zsh/
│       ├── .zshrc              ← Sources conf.d/*.zsh + inits Starship
│       └── conf.d/
│           ├── 01-environment.zsh   ← PATH, history, exports
│           ├── 02-completion.zsh    ← Tab completion, auto-pushd
│           ├── 03-oh-my-zsh.zsh     ← Plugin list, plugin config
│           ├── 04-keybindings.zsh   ← Emacs mode, arrow search
│           ├── 05-fzf.zsh          ← fd + bat integration
│           ├── 06-aliases.zsh       ← Git, navigation, modern replacements
│           ├── 07-functions.zsh     ← Custom functions
│           └── 99-local.zsh         ← Machine-specific (gitignored)
│
├── git/                        ← .gitconfig
├── starship/                   ← starship.toml
├── nvim/                       ← init.lua + lua/
├── tmux/                       ← .tmux.conf
├── bat/                        ← bat config
├── ripgrep/                    ← ripgrep config
└── fd/                         ← fd ignore patterns
```

Each directory is a **GNU Stow package** — its contents mirror `~/` and get symlinked there. You can stow/unstow individual packages independently.

## How It Works

```
~/.zshenv  →  dotfiles/zsh/.zshenv          (sets ZDOTDIR=~/.config/zsh)
                    ↓
~/.config/zsh/.zshrc                         (sources conf.d/*.zsh in order)
                    ↓
conf.d/01-environment.zsh                    (PATH, history, exports)
conf.d/02-completion.zsh                     (tab completion settings)
conf.d/03-oh-my-zsh.zsh                     (loads oh-my-zsh + plugins)
conf.d/04-keybindings.zsh                    (key bindings)
conf.d/05-fzf.zsh                           (fzf + fd + bat integration)
conf.d/06-aliases.zsh                        (all aliases)
conf.d/07-functions.zsh                      (custom functions)
conf.d/99-local.zsh                          (machine-specific, gitignored)
                    ↓
eval "$(starship init zsh)"                  (prompt)
```

## Installation

### Fresh Machine (full install)

```bash
git clone https://github.com/technomadindie/dotfiles-setup.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This will:
1. Backup existing configs to `~/.dotfiles_backup/<timestamp>/`
2. Install packages via Homebrew (macOS) or apt/dnf (Linux)
3. Install oh-my-zsh + custom plugins
4. Install TPM (tmux plugin manager) + Hack Nerd Font
5. Stow all config packages
6. Set zsh as default shell

### Individual Steps

```bash
./install.sh help             # Show all commands
./install.sh packages         # Install brew/apt/dnf packages only
./install.sh omz              # Install oh-my-zsh only
./install.sh omz-plugins      # Clone oh-my-zsh plugins only
./install.sh tpm              # Install tmux plugin manager only
./install.sh nerd-font        # Install Hack Nerd Font only
./install.sh stow             # Create symlinks only
./install.sh backup           # Backup existing configs only
./install.sh default-shell    # Set zsh as default shell only
```

## Post-Install

1. **New terminal** — open a new terminal or run `exec zsh`
2. **Tmux plugins** — open tmux, press `C-a + I` to install plugins
3. **Neovim plugins** — open `nvim`, lazy.nvim auto-installs on first launch
4. **Terminal font** — set your terminal emulator font to **Hack Nerd Font**
5. **Local config** — edit `~/.config/zsh/conf.d/99-local.zsh` for machine-specific settings

## Zsh Plugins

| Plugin | What it does |
|---|---|
| zsh-autosuggestions | Fish-like inline suggestions as you type |
| zsh-syntax-highlighting | Real-time command coloring (green=valid, red=error) |
| zsh-history-substring-search | Type partial command, up/down arrows filter history |
| zsh-completions | Extra completion definitions for hundreds of commands |
| fzf-tab | Replaces default tab completion with fzf fuzzy matching |
| extract | Universal `extract` command for any archive format |
| z | Frecency-based directory jumping (`z foo` → best match) |

## Key Aliases

| Alias | Command | Category |
|---|---|---|
| `gs` | `git status` | Git |
| `gc` | `git commit` | Git |
| `gd` | `git diff` | Git |
| `gco` | `git checkout` | Git |
| `glol` | `git log --graph --oneline --decorate` | Git |
| `gpush` | `git push origin HEAD` | Git |
| `ls` | `eza --icons --group-directories-first` | Modern |
| `ll` | `eza -l ... --sort=modified` | Modern |
| `cat` | `bat --paging=never` | Modern |
| `n` | `nvim` | Shortcut |
| `fs` | `fd --type f -H \| fzf` | Shortcut |
| `..` | `cd ../` | Navigation |
| `mkcd` | Create dir and cd into it | Function |

## Customization

### Adding Your Own Config

Edit `~/.config/zsh/conf.d/99-local.zsh` (gitignored) for machine-specific settings:

```zsh
# Example: work-specific tools
export PATH="$PATH:/opt/work-tools/bin"
alias vpn='sudo openconnect vpn.company.com'
```

### Adding a New Stow Package

To add a config for a new tool (e.g., `alacritty`):

```bash
mkdir -p ~/dotfiles/alacritty/.config/alacritty
# Create your config file:
vim ~/dotfiles/alacritty/.config/alacritty/alacritty.toml
# Stow it:
cd ~/dotfiles && stow alacritty
```

Then add `alacritty` to the `stow_packages` array in `install.sh`.

### Adding New Zsh Plugins

1. Add the plugin name to the `plugins=()` array in `conf.d/03-oh-my-zsh.zsh`
2. If it's a custom plugin (not built into oh-my-zsh), clone it:
   ```bash
   git clone https://github.com/user/plugin.git ~/.oh-my-zsh/custom/plugins/plugin
   ```
   And add the `clone_plugin` line in `install.sh` → `install_omz_plugins()`

### Adding New Aliases or Functions

Edit directly in `conf.d/06-aliases.zsh` or `conf.d/07-functions.zsh` — these are your personal files, no override layers.

### Changing the Prompt

Edit `starship/.config/starship.toml`. See [Starship docs](https://starship.rs/config/) for all options.

### Changing the Tmux Theme

In `.tmux.conf`, swap the theme plugin and settings:

```tmux
# Replace tmux-power with another theme:
set -g @plugin 'catppuccin/tmux'
# or
set -g @plugin 'dracula/tmux'
```

Then reload: `C-a + r` and reinstall plugins: `C-a + I`.

## Platform Notes

| | macOS | Linux (Debian/Ubuntu) | Linux (Fedora) |
|---|---|---|---|
| Package manager | Homebrew | apt | dnf |
| `bat` binary | `bat` | `batcat` (symlinked) | `bat` |
| `fd` binary | `fd` | `fdfind` (symlinked) | `fd` |
| `eza` | Homebrew | Ubuntu 24.04+ only | dnf |
| Clipboard (tmux) | `pbcopy` | `xclip` / `wl-copy` | `xclip` / `wl-copy` |
| Nerd Font dir | `~/Library/Fonts/` | `~/.local/share/fonts/` | `~/.local/share/fonts/` |
| `git-delta` | Homebrew | Manual install | dnf |
