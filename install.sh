#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "/etc/arch-release" ]; then
  echo "Arch Linux detected"
  exec "$SCRIPT_DIR/install_arch.sh"
elif [ -f "/etc/debian_version" ]; then
  echo "Ubuntu/Debian detected"
  exec "$SCRIPT_DIR/install_ubuntu.sh"
else
  echo "Unsupported distribution."
  echo "Available install scripts:"
  echo "  ./install_arch.sh    — Arch Linux"
  echo "  ./install_ubuntu.sh  — Ubuntu/Debian"
  exit 1
fi
