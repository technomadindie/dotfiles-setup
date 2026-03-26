# Aliases

# --- Navigation ---
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .-='cd -'

# --- Modern replacements ---
if (( $+commands[eza] )); then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --sort=modified'
    alias la='eza -la --icons --group-directories-first --sort=modified'
    alias lt='eza --tree --level=2 --icons'
else
    alias ll='ls -ltr'
    alias la='ls -altr'
fi

if (( $+commands[bat] )); then
    alias cat='bat --paging=never'
fi

# --- Shortcuts ---
alias c='clear'
alias h='history'
alias n='nvim'
alias re='realpath'
alias hg='history | grep'
alias resource='exec zsh'

# fd + fzf file search
if (( $+commands[fd] && $+commands[fzf] )); then
    alias fs='fd --type f -H | fzf'
fi

# --- Git ---
alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gpo='git push origin'
alias gplo='git pull origin'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gdt='git difftool'
alias gco='git checkout'
alias gl='git log'
alias glo='git log --pretty="oneline"'
alias glol='git log --graph --oneline --decorate'
alias gr='git remote'
alias grs='git remote show'
alias gpush='git push origin HEAD'
alias gpull='git fetch origin && git pull origin'

# --- Safety nets ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'
