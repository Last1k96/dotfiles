#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/Last1k96/dotfiles.git"
DOTFILES_DIR="$HOME/code/dotfiles"

# If not running from the cloned repo, clone it first
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "Cloning dotfiles repo..."
    sudo apt-get update && sudo apt-get install -y git
    mkdir -p "$HOME/code"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    echo "Re-running install from the cloned repo..."
    exec bash "$DOTFILES_DIR/install.sh"
fi

cd "$DOTFILES_DIR"

echo "=== Installing packages ==="
bash scripts/packages.sh

echo "=== Creating symlinks ==="
bash scripts/symlinks.sh

echo "=== Done! ==="
echo "Log out and back in (or run 'exec zsh') to apply shell changes."
