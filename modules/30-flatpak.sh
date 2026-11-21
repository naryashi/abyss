#!/usr/bin/env bash
# DESC: Flatpak apps (Discord, OBS, Spotify, VLC, Flatseal...)
# DEFAULT: on
set -eo pipefail

if ! command -v flatpak >/dev/null; then
  if command -v pacman >/dev/null; then
    sudo pacman -S --needed --noconfirm flatpak
  elif command -v apt-get >/dev/null; then
    sudo apt-get install -y flatpak
  else
    sudo dnf install -y flatpak
  fi
fi

sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo flatpak install -y flathub \
  com.discordapp.Discord \
  com.github.tchx84.Flatseal \
  com.mattjakeman.ExtensionManager \
  com.obsproject.Studio \
  com.spotify.Client \
  im.riot.Riot \
  io.github.flattool.Warehouse \
  io.github.giantpinkrobots.flatsweep \
  io.github.kolunmi.Bazaar \
  it.mijorus.gearlever \
  org.fedoraproject.MediaWriter \
  org.videolan.VLC \
  com.ranfdev.DistroShelf
