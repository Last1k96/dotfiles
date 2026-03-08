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
    pipx \
    xclip

# LLVM 20 apt repository
if [ ! -f /etc/apt/sources.list.d/llvm-20.list ]; then
    echo "Adding LLVM 20 apt repository..."
    curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg
    . /etc/os-release
    echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/${UBUNTU_CODENAME}/ llvm-toolchain-${UBUNTU_CODENAME}-20 main" \
        | sudo tee /etc/apt/sources.list.d/llvm-20.list
    sudo apt-get update
fi

# C++ development
sudo apt-get install -y \
    build-essential \
    cmake \
    cmake-curses-gui \
    ninja-build \
    gdb \
    clang-20 \
    clang-format-20 \
    clang-tidy-20 \
    clangd-20 \
    lld-20 \
    lldb-20 \
    libc++-20-dev \
    libc++abi-20-dev \
    libclang-20-dev \
    mold \
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

# Set up unversioned symlinks for LLVM 20 tools
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-20 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-20 100
sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-20 100
sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-20 100
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-20 100
sudo update-alternatives --install /usr/bin/lld lld /usr/bin/lld-20 100
sudo update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-20 100
sudo update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-20 100
sudo update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-20 100
sudo update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-20 100
sudo update-alternatives --install /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-20 100
sudo update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-20 100
sudo update-alternatives --install /usr/bin/llvm-strip llvm-strip /usr/bin/llvm-strip-20 100

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

# Yazi file manager
if ! command -v yazi &>/dev/null; then
    echo "Installing yazi..."
    curl -Lo /tmp/yazi.zip \
        https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
    unzip -o /tmp/yazi.zip -d /tmp/yazi
    sudo install -m 755 /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi
    rm -rf /tmp/yazi /tmp/yazi.zip
fi

# tree-sitter CLI (needed by nvim-treesitter)
if ! command -v tree-sitter &>/dev/null; then
    echo "Installing tree-sitter CLI..."
    curl -Lo /tmp/tree-sitter.gz \
        "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz"
    gunzip -f /tmp/tree-sitter.gz
    sudo install -m 755 /tmp/tree-sitter /usr/local/bin/tree-sitter
    rm /tmp/tree-sitter
fi

# Lazygit (latest from GitHub releases)
if ! command -v lazygit &>/dev/null; then
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
    curl -Lo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    sudo install -m 755 /dev/stdin /usr/local/bin/lazygit < <(tar -xzf /tmp/lazygit.tar.gz -O lazygit)
    rm /tmp/lazygit.tar.gz
fi

# Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# SSH key for GitHub
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "kurinmaksim42@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"
    echo ""
    echo "=== Add this SSH key to GitHub ==="
    echo "https://github.com/settings/ssh/new"
    echo ""
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    echo "=================================="
fi

# Set zsh as default shell (if not already)
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi
