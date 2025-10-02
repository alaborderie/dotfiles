#!/bin/bash
# install everything in wsl for my windows laptop from cdiscount
apt update
apt install build-essential git curl less software-properties-common ninja-build cmake
echo "adding repositories"
apt-add-repository ppa:fish-shell/release-3 && apt update
echo "installing fish..."
apt install fish
echo "setting fish as default shell..."
chsh -s $(which fish)
echo "installing starship..."
curl -sS https://starship.rs/install.sh | sh
echo "installing thefuck"
apt install thefuck
echo "install lazygit, fzf, ripgrep, fd"
apt install fzf ripgrep fd-find
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit -D -t /usr/local/bin/
echo "install neovim from source"
git clone https://github.com/neovim/neovim ~/temp_neovim
cd ~/temp_neovim
make CMAKE_BUILD_TYPE=Release
make install
cd
rm -rf temp_neovim
echo "copying dotfiles..."
cp -R .config/fish .config/git .config/starship.toml ~/.config/.
echo "updating XDG_CONFIG_HOME"
sed -i 's/\/home\/alaborderie/\/root' /root/.config/fish/fish_variables
echo "adding paths to fish..."
fish -c "fish_add_path /opt/homebrew/bin"
fish -c "fish_add_path /usr/local/bin"
echo "installing fisher and plugins..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"
