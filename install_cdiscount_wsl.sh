#!/bin/bash
# install everything in wsl for my windows laptop from cdiscount

# ─── base packages ────────────────────────────────────────────────────────────
apt update
apt install -y \
  build-essential git curl wget less software-properties-common \
  ninja-build cmake make \
  unzip bc nano dos2unix lsof \
  gettext binutils \
  ripgrep fd-find fzf \
  thefuck \
  btop ncdu neofetch \
  poppler-utils libxml2-utils \
  locales \
  iproute2 iptables iputils-ping dnsutils procps lsb-release \
  postgresql-client \
  kcat \
  kafkacat \
  python3-pip python3-venv python3-debugpy \
  lua5.4 luarocks \
  maven liquibase \
  xvfb \
  xsel \
  fonts-freefont-ttf fonts-ipafont-gothic fonts-liberation \
  fonts-noto-color-emoji fonts-tlwg-loma-otf fonts-unifont \
  fonts-wqy-zenhei xfonts-scalable \
  cookiecutter

# ─── fish shell ───────────────────────────────────────────────────────────────
echo "installing fish..."
apt install -y fish

# ─── github cli ───────────────────────────────────────────────────────────────
echo "installing gh..."
mkdir -p -m 755 /etc/apt/keyrings
wget -qO /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  https://cli.github.com/packages/githubcli-archive-keyring.gpg
chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  >/etc/apt/sources.list.d/github-cli.list
apt update
apt install -y gh

# ─── docker ───────────────────────────────────────────────────────────────────
echo "installing docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  >/etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ─── temurin jdk 21 ───────────────────────────────────────────────────────────
echo "installing temurin jdk 21..."
wget -qO /tmp/adoptium.gpg https://packages.adoptium.net/artifactory/api/gpg/key/public
gpg --dearmor </tmp/adoptium.gpg >/etc/apt/trusted.gpg.d/adoptium.gpg
rm /tmp/adoptium.gpg
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
  >/etc/apt/sources.list.d/adoptium.list
apt update
apt install -y temurin-21-jdk

# ─── dotnet sdk ───────────────────────────────────────────────────────────────
echo "installing dotnet sdk..."
wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
  -O /tmp/packages-microsoft-prod.deb
dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb
apt update
apt install -y dotnet-sdk-10.0

# ─── go ───────────────────────────────────────────────────────────────────────
echo "installing go..."
GO_VERSION=$(curl -fsSL "https://go.dev/dl/?mode=json" | grep -o '"go[0-9.]*"' | head -1 | tr -d '"')
curl -fsSL -o /tmp/go.tar.gz "https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz"
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >/etc/profile.d/go.sh

# ─── kubectl ──────────────────────────────────────────────────────────────────
echo "installing kubectl..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key |
  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' \
  >/etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list
apt update
apt install -y kubectl

# ─── k9s ──────────────────────────────────────────────────────────────────────
echo "installing k9s..."
K9S_VERSION=$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -fsSL -o /tmp/k9s.tar.gz \
  "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -C /usr/local/bin -xzf /tmp/k9s.tar.gz k9s
rm /tmp/k9s.tar.gz

# ─── google chrome ────────────────────────────────────────────────────────────
echo "installing google chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  -O /tmp/chrome.deb
apt install -y /tmp/chrome.deb
rm /tmp/chrome.deb

# ─── starship ─────────────────────────────────────────────────────────────────
echo "installing starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# ─── lazygit ──────────────────────────────────────────────────────────────────
echo "installing lazygit..."
LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
  grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -C /tmp -xzf /tmp/lazygit.tar.gz lazygit
install /tmp/lazygit -D -t /usr/local/bin/
rm /tmp/lazygit.tar.gz /tmp/lazygit

# ─── neovim from source ───────────────────────────────────────────────────────
echo "installing neovim from source..."
rm -rf /tmp/neovim
git clone https://github.com/neovim/neovim /tmp/neovim
cd /tmp/neovim
make CMAKE_BUILD_TYPE=Release
make install
cd
rm -rf /tmp/neovim

echo "cloning personal neovim config..."
rm -rf ~/.config/nvim
git clone https://github.com/alaborderie/nvim ~/.config/nvim

# ─── dotfiles ─────────────────────────────────────────────────────────────────
echo "copying dotfiles..."
cp -R .config/fish .config/git .config/starship.toml ~/.config/.
echo "updating XDG_CONFIG_HOME"
sed -i 's/\/home\/alaborderie/\/root/g' /root/.config/fish/fish_variables

# ─── fish paths & plugins ─────────────────────────────────────────────────────
echo "adding paths to fish..."
fish -c "fish_add_path /usr/local/bin"
fish -c "fish_add_path /usr/local/go/bin"
echo "installing fisher and plugins..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"

# ─── node (via nvm.fish) ──────────────────────────────────────────────────────
echo "installing node lts via nvm..."
fish -c "nvm install lts && nvm use lts"

# ─── npm globals ──────────────────────────────────────────────────────────────
echo "installing npm global packages..."
fish -c "npm install -g opencode-ai typescript typescript-language-server yaml-language-server pnpm"

# ─── rtk ──────────────────────────────────────────────────────────────────────
echo "installing rtk..."
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
rtk init -g --opencode

# ─── wezterm config ───────────────────────────────────────────────────────────
echo "copying wezterm config..."
cp .wezterm.lua /mnt/c/Users/antoine.laborderie/.wezterm.lua
