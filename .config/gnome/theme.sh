#!/usr/bin/env bash
# GNOME theme — Catppuccin Mocha (blue accent) for GTK 3/4, Shell, cursor.
# Idempotent.
set -euo pipefail

FLAVOR="mocha"
ACCENT="blue"
THEME_NAME="catppuccin-${FLAVOR}-${ACCENT}-standard+default"
THEME_TAG="v1.0.3"
THEME_URL="https://github.com/catppuccin/gtk/releases/download/${THEME_TAG}/${THEME_NAME}.zip"

CURSOR_NAME="catppuccin-${FLAVOR}-dark-cursors"
CURSOR_URL="https://github.com/catppuccin/cursors/releases/latest/download/${CURSOR_NAME}.zip"

THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.icons"
GTK4_DIR="$HOME/.config/gtk-4.0"
TMPDIR_THEME="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_THEME"' EXIT

mkdir -p "$THEMES_DIR" "$ICONS_DIR" "$GTK4_DIR"

# --- Install gnome-shell-extensions (provides User Themes) if missing ---
HAVE_USER_THEME=0
if gnome-extensions list 2>/dev/null | grep -q 'user-theme@gnome-shell-extensions'; then
  HAVE_USER_THEME=1
else
  echo "Installing gnome-shell-extensions via apt (sudo required)..."
  if sudo -n true 2>/dev/null || [ -t 0 ]; then
    sudo apt install -y gnome-shell-extensions && HAVE_USER_THEME=1
  else
    echo "  No interactive sudo; skipping. Run manually then re-run this script:"
    echo "    sudo apt install -y gnome-shell-extensions"
  fi
fi

# --- Download + extract GTK theme ---
if [ ! -d "$THEMES_DIR/$THEME_NAME" ]; then
  echo "Downloading $THEME_NAME ..."
  curl -fsSL -o "$TMPDIR_THEME/theme.zip" "$THEME_URL"
  unzip -q -o "$TMPDIR_THEME/theme.zip" -d "$THEMES_DIR"
else
  echo "$THEME_NAME already in $THEMES_DIR"
fi

# --- GTK4 / libadwaita: symlink css + assets ---
SRC4="$THEMES_DIR/$THEME_NAME/gtk-4.0"
if [ -d "$SRC4" ]; then
  ln -sfn "$SRC4/gtk.css"      "$GTK4_DIR/gtk.css"
  ln -sfn "$SRC4/gtk-dark.css" "$GTK4_DIR/gtk-dark.css"
  ln -sfn "$SRC4/assets"       "$GTK4_DIR/assets"
fi

# --- Download + extract cursor ---
if [ ! -d "$ICONS_DIR/$CURSOR_NAME" ]; then
  echo "Downloading $CURSOR_NAME ..."
  if curl -fsSL -o "$TMPDIR_THEME/cursor.zip" "$CURSOR_URL"; then
    unzip -q -o "$TMPDIR_THEME/cursor.zip" -d "$ICONS_DIR"
  else
    echo "Cursor download failed, skipping"
  fi
fi

# --- Enable User Themes extension (if package was installed) ---
if [ "$HAVE_USER_THEME" = "1" ]; then
  gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || \
    echo "User Themes extension not enabled (you may need to log out/in then re-run)"
fi

# --- Apply via dconf ---
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/desktop/interface/gtk-theme    "'$THEME_NAME'"
[ "$HAVE_USER_THEME" = "1" ] && \
  dconf write /org/gnome/shell/extensions/user-theme/name "'$THEME_NAME'"
[ -d "$ICONS_DIR/$CURSOR_NAME" ] && \
  dconf write /org/gnome/desktop/interface/cursor-theme "'$CURSOR_NAME'"

echo "Theme applied. If the shell theme didn't update, log out / log back in."
echo "  GTK theme:   $THEME_NAME"
echo "  Cursor:      $CURSOR_NAME"
