#!/usr/bin/env bash
# Install Ulauncher + Catppuccin Mocha Blue theme + wire keybind.
set -euo pipefail

VERSION="5.15.15"
DEB_URL="https://github.com/Ulauncher/Ulauncher/releases/download/${VERSION}/ulauncher_${VERSION}_all.deb"
CFG_DIR="$HOME/.config/ulauncher"
THEME_NAME="Catppuccin-Mocha-Blue"
TMPDIR_UL="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_UL"' EXIT

# --- Install .deb if missing ---
if ! command -v ulauncher >/dev/null 2>&1; then
  echo "Downloading Ulauncher $VERSION..."
  curl -fsSL -o "$TMPDIR_UL/ulauncher.deb" "$DEB_URL"
  sudo apt install -y "$TMPDIR_UL/ulauncher.deb"
fi

# --- Install Catppuccin theme (Mocha, Blue accent) ---
git clone --depth 1 https://github.com/catppuccin/ulauncher "$TMPDIR_UL/catppuccin"
cd "$TMPDIR_UL/catppuccin"
python3 install.py --flavor mocha --accent blue --radius 14

# --- Configure Ulauncher: theme + disable its own hotkey (GNOME binding does it) ---
mkdir -p "$CFG_DIR"
SETTINGS="$CFG_DIR/settings.json"
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi
python3 - "$SETTINGS" "$THEME_NAME" <<'PY'
import json, sys
path, theme = sys.argv[1], sys.argv[2]
with open(path) as f:
    cfg = json.load(f)
cfg["theme-name"] = theme
cfg["hotkey-show-app"] = ""
cfg["show-indicator-icon"] = False
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
PY

# --- Autostart at login (force XWayland so Ulauncher can self-center) ---
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/ulauncher.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Ulauncher
Comment=Application launcher
Exec=env GDK_BACKEND=x11 ulauncher --hide-window
Icon=ulauncher
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=2
NoDisplay=false
Terminal=false
EOF

# --- Update GNOME custom keybind to ulauncher-toggle (replaces rofi) ---
P=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1
dconf write "$P/name" "'ulauncher'"
dconf write "$P/command" "'ulauncher-toggle'"
dconf write "$P/binding" "'<Alt><Shift>Return'"

# --- Restart Ulauncher with XWayland backend so it picks up the centering ---
pkill -x ulauncher 2>/dev/null || true
sleep 0.3
GDK_BACKEND=x11 nohup ulauncher --hide-window >/dev/null 2>&1 &
disown || true

echo "Done. Theme: $THEME_NAME. Hotkey: <Alt><Shift>Return."
