#!/usr/bin/env bash
# DESC: CPU governor = performance (until next reboot)
# DISTRO: arch
set -eo pipefail
sudo pacman -S --needed --noconfirm cpupower
sudo cpupower frequency-set -g performance
