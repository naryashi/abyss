#!/usr/bin/env bash
# DESC: Update the whole system
# DEFAULT: on
set -eo pipefail
if command -v pacman >/dev/null; then
  sudo pacman -Syu --noconfirm
elif command -v apt-get >/dev/null; then
  sudo apt-get update
  sudo apt-get full-upgrade -y
else
  sudo dnf upgrade -y
fi
