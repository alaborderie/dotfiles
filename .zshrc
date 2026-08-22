export PATH="$HOME/.local/bin:$PATH"
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

# ── oh-my-zsh ────────────────────────────────────────────────────────────────
# theme: robbyrussell (default, minimal, plays nice with starship if active)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
# zsh-syntax-highlighting must be last; zsh-nvm lazy-loads nvm
export NVM_LAZY_LOAD=true
plugins=(
  git
  zsh-nvm
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# Up/Down arrows search history filtered by current prefix
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Larger, deduped, shared history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS INC_APPEND_HISTORY

# ── default editor ───────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── nvm ── handled lazily by the zsh-nvm plugin above ───────────────────────

# ── starship ─────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── forgit ───────────────────────────────────────────────────────────────────
[ -f "$HOME/.config/forgit/forgit.plugin.zsh" ] && source "$HOME/.config/forgit/forgit.plugin.zsh"

# ── git aliases ──────────────────────────────────────────────────────────────
alias gd='git diff'
alias gss='git status -s'
alias gcm='git commit -m'
alias gcb='git checkout -b'
alias gco='git checkout'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gca='git commit -v -a'
