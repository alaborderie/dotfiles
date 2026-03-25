#!/bin/bash
# Arch Linux install script
set -e

echo "=== Arch Linux Setup ==="

# Base tools + yay
echo "Installing base-devel, git, flatpak..."
sudo pacman -Sy --needed base-devel git flatpak

echo "Installing yay..."
if ! command -v yay &> /dev/null; then
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si
  cd ..
  rm -rf yay-bin
else
  echo "yay already installed, skipping"
fi

echo "Setting bash as default shell..."
sudo chsh -s "$(which bash)" "$USER"

echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh

echo "Installing thefuck..."
yay -Sy --needed thefuck

# Terminal & browser
echo "Installing ghostty and zen browser..."
yay -Sy --needed ghostty zen-browser-bin

# Editor & CLI tools
echo "Installing neovim, lazygit, fzf, ripgrep, fd, vim..."
yay -Sy --needed neovim lazygit fzf ripgrep fd vim less wget htop neofetch

echo "Cloning personal nvim config..."
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/alaborderie/nvim ~/.config/nvim
else
  echo "nvim config already exists, skipping"
fi

# Hyprland desktop environment
echo "Installing Hyprland and desktop packages..."
yay -Sy --needed \
  hyprland \
  hyprlock \
  hyprpaper \
  hyprshot \
  xdg-desktop-portal-hyprland \
  polkit-kde-agent \
  sddm

echo "Installing Wayland utilities..."
yay -Sy --needed \
  wl-clip-persist \
  brightnessctl \
  swayimg \
  grim \
  slurp

# Audio (PipeWire stack)
echo "Installing PipeWire audio stack..."
yay -Sy --needed \
  pipewire \
  pipewire-pulse \
  wireplumber

# Bar, launcher, notifications
echo "Installing waybar, rofi, mako, dunst..."
yay -Sy --needed \
  waybar \
  rofi \
  mako \
  dunst

# Desktop utilities
echo "Installing desktop utilities..."
yay -Sy --needed \
  thunar \
  pavucontrol \
  playerctl \
  libnotify \
  blueman \
  qt5ct \
  qt5-wayland \
  qt6-wayland \
  qt6-virtualkeyboard \
  phonon-qt6-mpv \
  bat \
  gparted \
  smartmontools

echo "Installing dev tools..."
yay -Sy --needed \
  docker-compose \
  github-cli \
  golangci-lint \
  k9s \
  openssh \
  python-pip \
  statusbar

echo "Installing system utilities..."
yay -Sy --needed zram-generator

# Rust
echo "Installing rustup and stable toolchain..."
yay -Sy --needed rustup
rustup default stable
rustup install stable

echo "Installing cargo tools..."
cargo install cargo-audit cargo-llvm-cov

echo "Installing docker..."
yay -Sy --needed docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker "$USER"

echo "Copying dotfiles..."
cp -R .config/* ~/.config/.
cp .bashrc ~/

echo "Installing nvm and node lts..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm install --lts


echo "Configuring hibernate delay..."
sudo sed -i 's/.*HibernateDelaySec=.*/HibernateDelaySec=900/g' /etc/systemd/sleep.conf

echo ""
echo "=== Arch Linux setup complete ==="
echo "NOTE: Log out and back in for docker group and default shell changes to take effect."
echo "NOTE: You may want to install opencode manually via npm (needs nvm/node)."
