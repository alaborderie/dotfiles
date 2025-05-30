#!/bin/bash
# install everything under macOS or linux
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "installing xcode-select for build tools (it's async, if something fails after please rerun the script)"
  xcode-select --install
  echo "installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  install_command="brew install"
elif [ -f "/etc/arch-release" ]; then
  echo "arch detected"
  echo "installing yay git and base-devel"
  sudo pacman -Sy --needed base-devel git flatpak
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si
  cd ..
  rm -rf yay-bin
  install_command="yay -Sy"
else
  echo "other distro detected, use apt and install git and build-essential"
  sudo apt update
  sudo apt install build-essential git flatpak curl less
  install_command="sudo apt install -y"
  echo "adding repositories"
  sudo apt-add-repository ppa:fish-shell/release-3 && sudo apt update
fi

echo "installing fish..."
$install_command fish
echo "setting fish as default shell..."
sudo chsh -s $(which fish)
echo "installing starship..."
curl -sS https://starship.rs/install.sh | sh
echo "installing thefuck"
$install_command thefuck
echo "installing ghostty and zen browser..."
if [[ "$install_command" == "brew"* ]]; then
  brew install --cask zen-browser
else
  $install_command ghostty zen-browser-bin
fi
echo "install neovim, lazygit, fzf, ripgrep, fd, and personal vim config"
$install_command neovim lazygit fzf ripgrep fd
git clone https://github.com/alaborderie/nvim ~/.config/nvim
echo "copying dotfiles..."
cp -R .config/* ~/.config/.
if [[ "$install_command" = "yay"* ]]; then
	$install_command pavucontrol hyprland hyprlock hyprpaper thunar waybar rofi mako bat wl-clip-persist
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "macOS detected so we change fish path in ghostty.conf"
  sed -i '' "s/\/bin\/fish/\/opt\/homebrew\/bin\/fish/g" ~/.config/ghostty/config
fi
echo "adding paths to fish..."
fish -c "fish_add_path /opt/homebrew/bin"
fish -c "fish_add_path /usr/local/bin"
echo "installing fisher and plugins..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"
echo "installing rustup and rust toolchain"
$install_command rustup
rustup default stable
rustup install stable
echo "installing docker"
$install_command docker
if [[ "$OSTYPE" == "darwin"* ]]; then
  brew install colima
  colima start
  mkdir ~/.docker/cli-plugins
  curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-darwin-aarch64 -o ~/.docker/cli-plugins/docker-compose
  curl -SL https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.darwin-arm64 -o ~/.docker/cli-plugins/docker-buildx
  chmod +x ~/.docker/cli-plugins/docker-*
else
  sudo systemctl start docker.service
  sudo systemctl enable docker.service
  sudo usermod -aG docker $USER
  newgrp docker
fi
