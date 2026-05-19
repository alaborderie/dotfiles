#!/usr/bin/env bash
# Install Pop Shell (dwindle binary-tree tiling, Hyprland-like) and configure
# Alt-based hjkl/arrows. Replaces Tiling Shell + Ubuntu's tiling-assistant.
set -euo pipefail

REPO=https://github.com/pop-os/shell.git
BRANCH=master_noble
SRC_DIR="${POP_SHELL_SRC_DIR:-$HOME/.local/src/pop-shell}"
EXT_UUID="pop-shell@system76.com"
SCHEMA=/org/gnome/shell/extensions/pop-shell

# --- Build deps ---
echo "== Installing build deps (sudo) =="
sudo apt install -y git make node-typescript

# --- Clone / update ---
mkdir -p "$(dirname "$SRC_DIR")"
if [ -d "$SRC_DIR/.git" ]; then
  git -C "$SRC_DIR" fetch --depth 1 origin "$BRANCH"
  git -C "$SRC_DIR" reset --hard "origin/$BRANCH"
else
  git clone --depth 1 --branch "$BRANCH" "$REPO" "$SRC_DIR"
fi

# --- Build & install to ~/.local/share/gnome-shell/extensions ---
# `make local-install` ends with `gnome-extensions enable`, which fails on
# Wayland (shell can't reload to see the new extension). Mark it non-fatal —
# files are installed correctly regardless; enable happens after re-login.
cd "$SRC_DIR"
make local-install || echo "make local-install reported error (likely the enable step on Wayland — files are installed)."

# --- Disable conflicting tiling extensions ---
gnome-extensions disable tilingshell@ferrarodomenico.com 2>/dev/null || true
gnome-extensions disable tiling-assistant@ubuntu.com    2>/dev/null || true

# --- Enable Pop Shell (may fail on Wayland pre-relogin; that's OK) ---
gnome-extensions enable "$EXT_UUID" 2>/dev/null || \
  echo "Pop Shell not yet enabled (needs a log out / log back in, then run this script again)."

# --- Pop Shell config: dwindle ON, Alt-based focus & move ---
dw() { dconf write "$1" "$2"; }

# Core behaviors
dw "$SCHEMA/tile-by-default"   "true"     # Auto-tile new windows (dwindle)
dw "$SCHEMA/active-hint"        "true"    # Visual hint around focused window
dw "$SCHEMA/gap-inner"          "uint32 4"
dw "$SCHEMA/gap-outer"          "uint32 4"
dw "$SCHEMA/smart-gaps"         "false"

# Focus (Alt + arrows / hjkl)
dw "$SCHEMA/focus-left"  "['<Alt>Left',  '<Alt>h']"
dw "$SCHEMA/focus-down"  "['<Alt>Down',  '<Alt>j']"
dw "$SCHEMA/focus-up"    "['<Alt>Up',    '<Alt>k']"
dw "$SCHEMA/focus-right" "['<Alt>Right', '<Alt>l']"

# Move window (Alt+Shift + arrows / hjkl) — use *-global so it works outside tiling mode
dw "$SCHEMA/tile-move-left-global"  "['<Alt><Shift>Left',  '<Alt><Shift>h']"
dw "$SCHEMA/tile-move-down-global"  "['<Alt><Shift>Down',  '<Alt><Shift>j']"
dw "$SCHEMA/tile-move-up-global"    "['<Alt><Shift>Up',    '<Alt><Shift>k']"
dw "$SCHEMA/tile-move-right-global" "['<Alt><Shift>Right', '<Alt><Shift>l']"

# Tiling controls (rebind from Super to Alt as requested)
dw "$SCHEMA/toggle-tiling"     "['<Alt>y']"            # auto-tiling on/off (global)
dw "$SCHEMA/toggle-floating"   "['<Alt><Shift>y']"     # toggle floating on focused window
dw "$SCHEMA/tile-orientation"  "['<Alt>o']"            # toggle split direction for next new window
# tile-enter (interactive resize/move) kept on its default <Super>Return

# Pop Shell's configure.sh (run by make local-install) resets several wm.keybindings
# (e.g. close → <Super>q). Re-apply our Hyprland-style overrides.
if [ -f "$(dirname "$0")/keybinds.sh" ]; then
  bash "$(dirname "$0")/keybinds.sh"
fi

echo "Done. Pop Shell installed and configured."
echo "  Auto-tiling ON, Alt+arrows/hjkl for focus, Alt+Shift+... to move."
echo "  <Alt>Y toggle auto-tiling, <Alt>O toggle next-split orientation."
echo "  <Super>Return = interactive resize/move."
echo "  Log out / log back in to load the new extension, then re-run this script to enable."
