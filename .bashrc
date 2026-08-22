# ── homebrew ─────────────────────────────────────────────────────────────────
# Puts /home/linuxbrew/.linuxbrew/bin in PATH (so zsh, brew, etc. are found).
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── rust ─────────────────────────────────────────────────────────────────────
# Homebrew's rustup keeps the cargo/rustc proxies in its own opt dir, not in
# the main brew bin, so add it to PATH explicitly.
if command -v brew >/dev/null 2>&1 && [ -d "$(brew --prefix rustup 2>/dev/null)/bin" ]; then
  export PATH="$(brew --prefix rustup)/bin:$PATH"
fi

# ── auto-exec zsh in interactive shells ──────────────────────────────────────
# `chsh` is blocked on AD/SSSD setups (user not in /etc/passwd), so promote
# zsh from inside bash whenever this shell is interactive.
if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1 && [ -z "$BASH_EXECVE_GUARD" ]; then
  export BASH_EXECVE_GUARD=1
  export SHELL="$(command -v zsh)"
  exec zsh
fi

# ── default editor ───────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── nvm ──────────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
nvm use --lts --silent 2>/dev/null

# ── starship ─────────────────────────────────────────────────────────────────
eval "$(starship init bash)"

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
