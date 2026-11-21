#!/usr/bin/env bash
# DESC: CRB + EPEL + base packages (distrobox, fish, kitty...)
# DISTRO: rhel
# DEFAULT: on
set -eo pipefail
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --set-enabled crb
sudo dnf install -y epel-release
sudo dnf install -y \
  distrobox gufw tree kitty flatpak git curl fish snapper \
  gnome-disk-utility baobab wget ncdu
