#!/bin/bash
# Ubuntu/Debian install script
set -e

echo "=== Ubuntu/Debian Setup ==="

echo "Updating packages and installing base tools..."
sudo apt update
sudo apt install -y build-essential git flatpak curl less wget htop vim openssh-client python3-pip

echo "Adding fish PPA..."
sudo apt-add-repository -y ppa:fish-shell/release-3
sudo apt update

echo "Installing fish..."
sudo apt install -y fish
echo "Setting fish as default shell..."
sudo chsh -s "$(which fish)" "$USER"

echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh

echo "Installing thefuck..."
sudo apt install -y thefuck

echo "Installing neovim, fzf, ripgrep, fd, bat..."
sudo apt install -y neovim fzf ripgrep fd-find bat

echo "Installing lazygit..."
if ! command -v lazygit &> /dev/null; then
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz
fi

echo "Installing ghostty..."
if ! command -v ghostty &> /dev/null; then
  echo "NOTE: ghostty is not in default Ubuntu repos."
  echo "Install from: https://ghostty.org/docs/install"
  echo "Skipping..."
fi

echo "Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh
fi

echo "Cloning personal nvim config..."
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/alaborderie/nvim ~/.config/nvim
else
  echo "nvim config already exists, skipping"
fi

echo "Copying dotfiles..."
cp -R .config/* ~/.config/.

echo "Adding paths to fish..."
fish -c "fish_add_path /usr/local/bin"

echo "Installing fisher and plugins..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"

echo "Installing rustup and stable toolchain..."
if ! command -v rustup &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi
rustup default stable
rustup install stable

echo "Installing cargo tools..."
cargo install cargo-audit cargo-llvm-cov

echo "Installing docker..."
sudo apt install -y docker.io docker-compose-v2
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker "$USER"

echo ""
echo "=== Ubuntu/Debian setup complete ==="
echo "NOTE: Log out and back in for docker group and default shell changes to take effect."
echo "NOTE: Install ghostty manually if skipped: https://ghostty.org/docs/install"
echo "NOTE: Install opencode via npm: npm install -g opencode-ai"
echo "NOTE: For k9s: snap install k9s or download from https://github.com/derailed/k9s"
echo "NOTE: For golangci-lint: https://golangci-lint.run/welcome/install/"
