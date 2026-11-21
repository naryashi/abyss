#!/usr/bin/env bash
# DESC: Starship prompt (+ enable it in fish)
set -eo pipefail
curl -sS https://starship.rs/install.sh | sh -s -- -y

mkdir -p ~/.config/fish
line='starship init fish | source'
grep -qxF "$line" ~/.config/fish/config.fish 2>/dev/null \
  || echo "$line" >> ~/.config/fish/config.fish
