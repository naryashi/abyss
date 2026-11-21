#!/usr/bin/env bash
# DESC: Firewall on (ufw / firewalld) + automatic security updates
set -eo pipefail
if command -v pacman >/dev/null; then
  sudo pacman -S --needed --noconfirm ufw
  sudo systemctl enable --now ufw.service
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw --force enable
elif command -v apt-get >/dev/null; then
  sudo apt-get install -y ufw unattended-upgrades
  sudo systemctl enable --now ufw.service
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw --force enable
  printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n' \
    | sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
else
  sudo dnf upgrade --security -y
  sudo systemctl enable --now firewalld
fi
