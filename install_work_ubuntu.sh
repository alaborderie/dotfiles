#!/bin/bash
# install everything on ubuntu 24.04 for my linux laptop from <<TO_FILL>>
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running base Ubuntu install..."
bash "$SCRIPT_DIR/install_ubuntu.sh"

BREW_BIN=""

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    BREW_BIN="$(command -v brew)"
    return
  fi

  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
    return
  fi

  echo "brew is required but was not found after running install_ubuntu.sh"
  exit 1
}

brew_cmd() {
  "$BREW_BIN" "$@"
}

install_brew_packages() {
  if [ "$#" -eq 0 ]; then
    return
  fi

  local missing=()
  local pkg

  for pkg in "$@"; do
    if brew_cmd list --formula "$pkg" >/dev/null 2>&1; then
      echo "$pkg already installed, skipping"
    else
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    brew_cmd install "${missing[@]}"
  fi
}

ensure_homebrew

echo "Updating Homebrew..."
brew_cmd update

echo "Installing extra <<TO_FILL>> packages..."
install_brew_packages \
  unzip \
  bc \
  lsof \
  cmake \
  ninja \
  gettext \
  binutils \
  btop \
  ncdu \
  postgresql \
  kcat \
  lua \
  luarocks \
  xsel \
  xclip \
  jq \
  kubectl \
  openjdk@21 \
  openjdk \
  go \
  tmux

echo "Installing k9s..."
install_brew_packages k9s

echo "Cloning personal neovim config..."
rm -rf ~/.config/nvim
git clone https://github.com/alaborderie/nvim ~/.config/nvim

echo "Copying dotfiles..."
mkdir -p ~/.config
cp -R .config/git .config/starship.toml ~/.config/.
cp .bashrc ~/
cp .zshrc ~/

echo "Copying work configs (claude + opencode)..."
mkdir -p ~/.claude ~/.config/opencode/plugins
cp .config_work/.claude.json ~/.claude.json
cp .config_work/claude/settings.json ~/.claude/settings.json
cp .config_work/claude/CLAUDE.md ~/.claude/CLAUDE.md
cp .config_work/claude/RTK.md ~/.claude/RTK.md
cp .config_work/opencode/opencode.json ~/.config/opencode/opencode.json
cp .config_work/opencode/dcp.jsonc ~/.config/opencode/dcp.jsonc
cp .config_work/opencode/plugins/rtk.ts ~/.config/opencode/plugins/rtk.ts
cat > ~/.config/opencode/.gitignore <<'EOF'
node_modules
package.json
package-lock.json
bun.lock
.gitignore
EOF

echo "WARNING: secrets in copied configs are placeholders <<TO_FILL>>."
echo "  edit the following files and replace <<TO_FILL>> with real tokens:"
echo "    ~/.claude.json                    (AZURE_DEVOPS_PAT, github Authorization)"
echo "    ~/.config/opencode/opencode.json  (JIRA_API_TOKEN, CONFLUENCE_API_TOKEN, AZURE_DEVOPS_PAT)"

echo "Installing npm global packages..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
npm install -g opencode-ai typescript typescript-language-server yaml-language-server pnpm

echo "Installing claude code"
curl -fsSL https://claude.ai/install.sh | bash

echo "Installing rtk..."
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
rtk init -g
rtk init -g --opencode --claude-md
