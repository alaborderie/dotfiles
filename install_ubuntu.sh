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
  zsh

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
sudo chsh -s "$(which zsh)" "$USER" ||
  echo "chsh failed (likely AD/SSSD-managed user) — .bashrc will exec zsh on interactive sessions instead."

echo "Installing additional CLI tools from Arch setup..."
sudo apt install neofetch
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

echo "Installing nvm and node lts..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm install --lts

echo "Installing rustup and stable toolchain..."
if ! command -v rustup >/dev/null 2>&1; then
  install_brew_packages rustup
fi
source "$HOME/.cargo/env"
rustup default stable
rustup install stable

echo "Installing cargo tools..."
cargo install cargo-audit cargo-llvm-cov

echo "Installing docker..."
install_brew_packages docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker "$USER"

echo "Installing GNOME desktop bits (user-theme extension)..."
sudo apt install -y gnome-shell-extensions

echo "Installing Ulauncher + Catppuccin theme..."
bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/ulauncher-install.sh" ||
  echo "Ulauncher install failed (non-fatal, continuing)"

echo "Installing Pop Shell (dwindle tiling)..."
bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/pop-shell-install.sh" ||
  echo "Pop Shell install failed (non-fatal, continuing)"

echo "Installing OpenRazer (PPA + driver + daemon + python bindings)..."
if ! dpkg -l openrazer-meta 2>/dev/null | grep -q '^ii'; then
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y ppa:openrazer/stable
  sudo apt update
  sudo apt install -y "linux-headers-$(uname -r)" openrazer-meta || \
    sudo apt install -y linux-headers-generic openrazer-meta
fi
sudo gpasswd -a "$USER" plugdev || true

echo "Cloning RazerBatteryTray and building its venv..."
RBT_DIR="$HOME/perso/RazerBatteryTray"
mkdir -p "$HOME/perso"
if [ ! -d "$RBT_DIR" ]; then
  git clone https://github.com/HoroTW/RazerBatteryTray "$RBT_DIR"
fi
if [ ! -x "$RBT_DIR/.venv/bin/razer-battery-tray" ]; then
  python3 -m venv --system-site-packages "$RBT_DIR/.venv"
  "$RBT_DIR/.venv/bin/pip" install --upgrade pip
  "$RBT_DIR/.venv/bin/pip" install -e "$RBT_DIR"
fi

echo "Installing razer-battery-tray-wait helper to ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
install -m 0755 "$(dirname "${BASH_SOURCE[0]}")/.local/bin/razer-battery-tray-wait" \
  "$HOME/.local/bin/razer-battery-tray-wait"

echo "Enabling Razer battery tray user service..."
systemctl --user daemon-reload || true
systemctl --user enable --now razer-battery-tray.service ||
  echo "Failed to enable razer-battery-tray.service (non-fatal — may need a reboot for openrazer DKMS + plugdev group to apply)"

echo "Applying GNOME keybinds..."
if command -v gsettings >/dev/null 2>&1; then
  bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/keybinds.sh" ||
    echo "GNOME keybinds script failed (non-fatal, continuing)"
  bash "$(dirname "${BASH_SOURCE[0]}")/.config/gnome/theme.sh" ||
    echo "GNOME theme script failed (non-fatal, continuing)"
else
  echo "gsettings not found, skipping GNOME setup"
fi

echo ""
echo "=== Ubuntu/Debian setup complete ==="
echo "NOTE: Log out and back in for docker group changes to take effect."
echo "NOTE: Homebrew shell env can be loaded with: eval \"$($BREW_BIN shellenv)\""
echo "NOTE: Install opencode via npm: npm install -g opencode-ai"
