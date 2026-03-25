# ── nvm ──────────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
nvm use --lts --silent 2>/dev/null

# ── starship ─────────────────────────────────────────────────────────────────
eval "$(starship init bash)"

# ── thefuck ──────────────────────────────────────────────────────────────────
eval "$(thefuck --alias)"

# ── forgit ───────────────────────────────────────────────────────────────────
[ -f "$HOME/.config/forgit/forgit.plugin.sh" ] && source "$HOME/.config/forgit/forgit.plugin.sh"

# ── git aliases ──────────────────────────────────────────────────────────────
alias gd='git diff'
alias gss='git status -s'
alias gcm='git commit -m'
alias gcb='git checkout -b'
alias gco='git checkout'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gca='git commit -v -a'
