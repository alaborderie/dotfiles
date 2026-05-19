#!/usr/bin/env bash
# GNOME keybinds — Hyprland-like layout for Ubuntu 24.04 + Pop Shell
# Uses `dconf write` because `gsettings set` is unreliable for some keybinding
# schemas on Ubuntu 24.04 GNOME (returns success but does not persist).
# Idempotent: re-running just resets the same values.
set -euo pipefail

WM=/org/gnome/desktop/wm/keybindings
WMPREFS=/org/gnome/desktop/wm/preferences
MUTTER=/org/gnome/mutter
SHELL_KEYS=/org/gnome/shell/keybindings
MEDIA=/org/gnome/settings-daemon/plugins/media-keys

dw() { dconf write "$1" "$2"; }

# --- Workspaces: 10 fixed (instead of dynamic) ---
dw "$MUTTER/dynamic-workspaces" "false"
dw "$WMPREFS/num-workspaces" "10"

# --- Per-monitor workspaces: switching only affects the primary monitor,
#     the secondary stays pinned (closest GNOME gets to Hyprland's model) ---
dw "$MUTTER/workspaces-only-on-primary" "true"

# --- ALT+1..0 -> switch workspace 1..10 ---
for i in 1 2 3 4 5 6 7 8 9; do
  dw "$WM/switch-to-workspace-$i" "['<Alt>$i']"
done
dw "$WM/switch-to-workspace-10" "['<Alt>0']"

# --- ALT+SHIFT+1..0 -> move active window to workspace ---
for i in 1 2 3 4 5 6 7 8 9; do
  dw "$WM/move-to-workspace-$i" "['<Alt><Shift>$i']"
done
dw "$WM/move-to-workspace-10" "['<Alt><Shift>0']"

# --- Window actions ---
dw "$WM/close" "['<Alt>q', '<Alt>F4']"
dw "$WM/toggle-fullscreen" "['<Alt>f']"

# --- Screenshot UI (region/window/screen picker) on Alt+S ---
dw "$SHELL_KEYS/show-screenshot-ui" "['<Alt>s', 'Print']"

# Disable conflicts that would steal our combos
dw "$WM/begin-move" "@as []"
dw "$WM/activate-window-menu" "@as []"

# --- Screen lock: restore default Super+L (Pop Shell's configure.sh moves it to Super+Escape) ---
dw "$MEDIA/screensaver" "['<Super>l']"

# --- Mouse: ALT + left-drag to move window ---
dw "$WMPREFS/mouse-button-modifier" "'<Alt>'"

# --- Resize: ALT_R not distinguishable in GNOME, fallback on Super+R (interactive resize) ---
dw "$WM/begin-resize" "['<Super>r']"

# --- Focus / move tiled windows: handled by Pop Shell (pop-shell-install.sh) ---
# Alt+arrows or Alt+hjkl for focus; Alt+Shift+... to move.

# --- Custom app launchers (ALT+Return ghostty, etc.) ---
declare -a CK=(
  "ghostty|<Alt>Return|ghostty"
  "ulauncher|<Alt><Shift>Return|ulauncher-toggle"
  "thunar|<Alt>e|thunar"
  "pavucontrol|<Alt><Shift>p|pavucontrol"
)

paths=()
i=0
for entry in "${CK[@]}"; do
  IFS='|' read -r name binding command <<<"$entry"
  path="$MEDIA/custom-keybindings/custom$i/"
  paths+=("'$path'")
  dw "${path}name" "'$name'"
  dw "${path}command" "'$command'"
  dw "${path}binding" "'$binding'"
  i=$((i+1))
done

joined=$(IFS=,; echo "${paths[*]}")
dw "$MEDIA/custom-keybindings" "[$joined]"

echo "Keybinds applied. Log out / log back in if workspace count didn't refresh."
