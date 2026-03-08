#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/code/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"

# Symlink a file: create parent dirs, back up existing files, then link.
#   link <source_relative_to_config> <target>
link() {
    local src="$CONFIG_DIR/$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "SKIP (source missing): $src"
        return
    fi

    mkdir -p "$(dirname "$dst")"

    # Back up existing file (not symlink) if present
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "BACKUP: $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sfn "$src" "$dst"
    echo "LINK: $dst -> $src"
}

# Home directory dotfiles
link ".zshenv"      "$HOME/.zshenv"
link ".gitconfig"   "$HOME/.gitconfig"
link ".tmux.conf"   "$HOME/.tmux.conf"

# XDG config directories
link ".config/zsh"           "$HOME/.config/zsh"
link ".config/lazyvim"       "$HOME/.config/lazyvim"
link ".config/starship.toml" "$HOME/.config/starship.toml"
