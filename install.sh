#!/bin/bash
# install everything under macOS or linux
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "installing homebrew...";
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";

  install_command="brew install"
elif [ -f "/etc/arch-release" ]; then
  echo "arch detected"
  echo "installing yay git and base-devel"
  sudo pacman -Sy --needed base-devel git flatpak
  git clone https://aur.archlinux.org/yay.git
  cd yay-bin
  makepkg -si
  install_command="yay -Sy"
else
  echo "other distro detected, use apt and install git and build-essential"
  sudo apt update
  sudo apt install build-essential git flatpak
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
echo "installing alacritty fira code nerd font and zen browser..."
if [[ "$install_command" == "brew"* ]]; then
  brew install --cask alacritty font-fira-code-nerd-font zen-browser
  xattr -dr com.apple.quarantine "/Applications/Alacritty.app"
else
  $install_command alacritty ttf-firacode-nerd
  flatpak install flathub io.github.zen_browser.zen
fi
echo "installing spacevim"
curl -sLf https://spacevim.org/install.sh | bash
echo "copying dotfiles..."
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/fish
cp alacritty.toml ~/.config/alacritty/.
cp config.fish fish_plugins ~/.config/fish/.
cp starship.toml ~/.config/.
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "macOS detected so we change fish path in alacritty.toml"
  sed -i '' "s/\/bin\/fish/\/opt\/homebrew\/bin\/fish/g" ~/.config/alacritty/alacritty.toml
fi
echo "adding paths to fish..."
fish -c "fish_add_path /opt/homebrew/bin"
fish -c "fish_add_path /usr/local/bin"
echo "installing fisher and plugins..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"
