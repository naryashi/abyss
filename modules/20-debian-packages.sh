#!/usr/bin/env bash
# DESC: Base packages (distrobox, fish, kitty, snapper, ufw...)
# DISTRO: debian
# DEFAULT: on
set -eo pipefail
sudo apt-get update
sudo apt-get install -y \
  distrobox tree kitty flatpak git curl fish gufw ufw snapper \
  gnome-disk-utility baobab wget ncdu gamemode
