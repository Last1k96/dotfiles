#!/usr/bin/env bash
set -uo pipefail

FAILED=()

# Helper: run a named install step; log failures but continue.
run_step() {
    local name="$1"
    shift
    echo "--- $name ---"
    if "$@"; then
        echo "OK: $name"
    else
        echo "FAILED: $name (exit $?)"
        FAILED+=("$name")
    fi
}

sudo apt-get update && sudo apt-get upgrade -y

# Base tools (critical — abort if this fails)
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

install_llvm() {
    if command -v clang-20 &>/dev/null; then return 0; fi
    curl -fsSL https://apt.llvm.org/llvm.sh | sudo bash -s -- 20 all
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
}
run_step "LLVM 20" install_llvm

install_cpp_tools() {
    sudo apt-get install -y \
        build-essential \
        cmake \
        cmake-curses-gui \
        ninja-build \
        gdb \
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
        patchelf
    # linux-tools-common often missing on WSL; install separately
    sudo apt-get install -y linux-tools-common 2>/dev/null || true
}
run_step "C++ development tools" install_cpp_tools

# Network filesystems
run_step "Network filesystems" sudo apt-get install -y nfs-common cifs-utils

install_starship() {
    command -v starship &>/dev/null && return 0
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
}
run_step "Starship prompt" install_starship

install_neovim() {
    command -v nvim &>/dev/null && return 0
    curl -Lo /tmp/nvim-linux-x86_64.tar.gz \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
    rm /tmp/nvim-linux-x86_64.tar.gz
}
run_step "Neovim" install_neovim

install_yazi() {
    command -v yazi &>/dev/null && return 0
    curl -Lo /tmp/yazi.zip \
        https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
    unzip -o /tmp/yazi.zip -d /tmp/yazi
    sudo install -m 755 /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi
    rm -rf /tmp/yazi /tmp/yazi.zip
}
run_step "Yazi" install_yazi

install_tree_sitter() {
    command -v tree-sitter &>/dev/null && return 0
    curl -Lo /tmp/tree-sitter.gz \
        "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz"
    gunzip -f /tmp/tree-sitter.gz
    sudo install -m 755 /tmp/tree-sitter /usr/local/bin/tree-sitter
    rm /tmp/tree-sitter
}
run_step "tree-sitter CLI" install_tree_sitter

install_lazygit() {
    command -v lazygit &>/dev/null && return 0
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
    curl -Lo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    sudo install -m 755 /dev/stdin /usr/local/bin/lazygit < <(tar -xzf /tmp/lazygit.tar.gz -O lazygit)
    rm /tmp/lazygit.tar.gz
}
run_step "Lazygit" install_lazygit

install_tpm() {
    [ -d "$HOME/.tmux/plugins/tpm" ] && return 0
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
}
run_step "TPM (Tmux Plugin Manager)" install_tpm

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
    sudo chsh -s "$(which zsh)" "$USER"
fi

# Summary
if [ ${#FAILED[@]} -gt 0 ]; then
    echo ""
    echo "=== WARNING: The following steps failed ==="
    printf '  - %s\n' "${FAILED[@]}"
    echo "You can re-run install.sh to retry them."
    echo "============================================"
fi
