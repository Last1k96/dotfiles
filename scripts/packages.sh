#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update && sudo apt-get upgrade -y

# Base tools
sudo apt-get install -y \
    git \
    git-lfs \
    curl \
    wget \
    unzip \
    zip \
    tar \
    zsh \
    tmux \
    ripgrep \
    fd-find \
    fzf \
    jq \
    htop \
    tree \
    mc \
    fonts-font-awesome \
    python3-pip \
    pipx

# C++ development
sudo apt-get install -y \
    build-essential \
    cmake \
    cmake-curses-gui \
    ninja-build \
    gdb \
    clang \
    clang-format \
    clang-tidy \
    clangd \
    lldb \
    valgrind \
    ccache \
    cppcheck \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    checkinstall \
    autoconf \
    flex \
    bison \
    libtbb-dev \
    libusb-1.0-0-dev \
    libtool \
    patchelf \
    linux-tools-common

# Network filesystems
sudo apt-get install -y \
    nfs-common \
    cifs-utils

# Starship prompt
if ! command -v starship &>/dev/null; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Neovim (latest stable from GitHub releases)
if ! command -v nvim &>/dev/null; then
    echo "Installing neovim..."
    curl -Lo /tmp/nvim-linux-x86_64.tar.gz \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
    rm /tmp/nvim-linux-x86_64.tar.gz
fi

# Set zsh as default shell (if not already)
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi
