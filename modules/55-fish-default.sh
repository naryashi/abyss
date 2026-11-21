#!/usr/bin/env bash
# DESC: Make fish the default shell (asks your password)
set -eo pipefail
fish_path=$(command -v fish) || { echo "fish is not installed"; exit 1; }
chsh -s "$fish_path"
