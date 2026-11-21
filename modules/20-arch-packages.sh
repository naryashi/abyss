#!/usr/bin/env bash
# DESC: Base packages (distrobox, fish, snapper, ufw, gamemode...)
# DISTRO: arch
# DEFAULT: on
set -eo pipefail
sudo pacman -S --needed --noconfirm \
  distrobox tree flatpak pfetch git curl fish gufw btrfs-assistant snapper \
  gnome-disk-utility bashtop baobab wget ncdu ufw gamemode
