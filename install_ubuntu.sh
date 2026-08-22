#!/bin/bash
# Ubuntu/Debian install script
set -e

echo "=== Ubuntu/Debian Setup ==="

BREW_BIN=""

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    BREW_BIN="$(command -v brew)"
    return
  fi

  echo "Installing Homebrew prerequisites..."
  sudo apt update
  sudo apt install -y build-essential procps curl file git

  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
  elif [ -x /opt/homebrew/bin/brew ]; then
    BREW_BIN="/opt/homebrew/bin/brew"
  else
    echo "brew installation failed"
    exit 1
  fi
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

# Make brew + brew-installed bins available to GUI apps and future login shells.
if ! grep -q "linuxbrew.*shellenv" "$HOME/.profile" 2>/dev/null; then
  cat >> "$HOME/.profile" <<'EOF'

# ── homebrew (so GUI apps and login shells find brew + brew-installed bins) ──
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
EOF
fi
eval "$($BREW_BIN shellenv)"

echo "Updating Homebrew..."
brew_cmd update

echo "Installing base CLI tools..."
install_brew_packages \
  git \
  neovim \
  lazygit \
  fzf \
  ripgrep \
  fd \
  vim \
  less \
  wget \
  htop \
  bat \
  gh \
  openssh \
  python@3.13 \
  zsh \
  wl-clipboard

echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh

echo "Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "oh-my-zsh already installed, skipping"
fi

echo "Installing zsh plugins (autosuggestions, syntax-highlighting, history-substring-search)..."
ZSH_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
for repo in \
  "zsh-users/zsh-autosuggestions" \
  "zsh-users/zsh-syntax-highlighting" \
  "zsh-users/zsh-history-substring-search" \
  "lukechilds/zsh-nvm"; do
  name="${repo#*/}"
  dest="$ZSH_PLUGINS/$name"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --quiet
  else
    git clone --depth 1 "https://github.com/$repo" "$dest"
  fi
done

echo "Setting zsh as default shell..."
# The shell must be listed in /etc/shells: AccountsService hides users with an
# unlisted login shell, which makes GDM think no users exist and boot into
# gnome-initial-setup instead of the login screen.
ZSH_PATH="$(which zsh)"
grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
sudo chsh -s "$ZSH_PATH" "$USER" ||
  echo "chsh failed (likely AD/SSSD-managed user) — .bashrc will exec zsh on interactive sessions instead."

echo "Installing additional CLI tools from Arch setup..."
sudo apt install fastfetch
install_brew_packages \
  docker-compose \
  golangci-lint \
  k9s \
  smartmontools

echo "Cloning personal nvim config..."
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/alaborderie/nvim ~/.config/nvim
else
  echo "nvim config already exists, skipping"
fi

echo "Copying dotfiles..."
mkdir -p ~/.config
cp -R .config/* ~/.config/.
cp .bashrc ~/
cp .zshrc ~/
cp .zprofile ~/

echo "Installing nvm and node lts..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm install --lts

echo "Installing rustup and stable toolchain..."
if ! command -v rustup >/dev/null 2>&1 && [ ! -f "$HOME/.cargo/env" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
fi
source "$HOME/.cargo/env"
rustup default stable

echo "Installing cargo tools..."
cargo install cargo-audit cargo-llvm-cov

echo "Installing docker..."
if ! command -v docker >/dev/null 2>&1; then
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"

echo "Installing GNOME desktop bits (user-theme extension)..."
sudo apt install -y gnome-shell-extensions

echo "Installing Ulauncher + Catppuccin theme..."
bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/ulauncher-install.sh" ||
  echo "Ulauncher install failed (non-fatal, continuing)"

echo "Installing Pop Shell (dwindle tiling)..."
bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/pop-shell-install.sh" ||
  echo "Pop Shell install failed (non-fatal, continuing)"

echo "Applying GNOME keybinds..."
if command -v gsettings >/dev/null 2>&1; then
  bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/keybinds.sh" ||
    echo "GNOME keybinds script failed (non-fatal, continuing)"
  bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/theme.sh" ||
    echo "GNOME theme script failed (non-fatal, continuing)"
else
  echo "gsettings not found, skipping GNOME setup"
fi

echo "Installing additional software"
brew install thefuck
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
curl -fsSL https://claude.ai/install.sh | bash

echo ""
echo "=== Ubuntu/Debian setup complete ==="
echo "NOTE: Log out and back in for docker group changes to take effect."
echo "NOTE: Homebrew shell env can be loaded with: eval \"$($BREW_BIN shellenv)\""
echo "NOTE: Install opencode via npm: npm install -g opencode-ai"
