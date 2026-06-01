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

# Pull current stable git from the git-core PPA before the main install. Ubuntu LTSes
# (jammy: 2.34, noble: 2.43) ship git versions with a submodule remote-resolution bug
# where `git submodule update --init` invokes `git fetch <remote> <sha>` using the
# superproject's default remote name rather than the submodule's — breaking nested
# superprojects whose tracking branch isn't called "origin". Fixed upstream in 2.49.
install_git_ppa() {
    if [ ! -f /etc/os-release ] || ! grep -q '^ID=ubuntu' /etc/os-release; then
        echo "Not Ubuntu — skipping git-core PPA"
        return 0
    fi
    if grep -rq "git-core/ppa" /etc/apt/sources.list.d/ 2>/dev/null; then
        echo "git-core PPA already configured"
        return 0
    fi
    sudo apt-get install -y software-properties-common || return 1
    # Fail-loud: add-apt-repository talks to api.launchpad.net via Python urllib and the
    # silent-timeout failure mode (when http_proxy is bare host:port instead of URL form)
    # otherwise hides itself behind the next apt-get update succeeding against stock repos.
    sudo add-apt-repository -y ppa:git-core/ppa || return 1
    sudo apt-get update || return 1
}
run_step "git-core PPA (latest git)" install_git_ppa

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
    bat \
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
    # mold is installed below from upstream for the latest version; the apt
    # package is a fallback in case the upstream install step fails.
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

# Speed up `git status` in large/submoduled repos by giving git an external filesystem
# monitor. Upstream git (and the git-core PPA's binary) ship only darwin/win32 backends
# for the built-in `git fsmonitor--daemon`; on Linux, even microsoft-git's official .deb
# doesn't enable the Linux backend. The portable answer is Facebook's `watchman` daemon
# bridged via git's built-in fsmonitor-watchman Perl hook (shipped in
# /usr/share/git-core/templates/hooks/fsmonitor-watchman.sample by the apt git package).
# core.fsMonitor in the dotfile .gitconfig is set to that script's path; this step just
# installs the watchman binary it talks to.
install_git_fsmonitor() {
    command -v watchman &>/dev/null && return 0
    sudo apt-get install -y watchman
}
run_step "watchman (external fsmonitor for git)" install_git_fsmonitor

install_mold() {
    local latest_ver
    latest_ver=$(curl -s https://api.github.com/repos/rui314/mold/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    if command -v mold &>/dev/null && [[ "$(mold --version)" == *"$latest_ver"* ]]; then return 0; fi
    curl -fSL -o /tmp/mold.tar.gz \
        "https://github.com/rui314/mold/releases/download/v${latest_ver}/mold-${latest_ver}-x86_64-linux.tar.gz"
    tar -C /tmp -xzf /tmp/mold.tar.gz
    sudo install -m 755 /tmp/mold-${latest_ver}-x86_64-linux/bin/mold /usr/local/bin/mold
    sudo cp -r /tmp/mold-${latest_ver}-x86_64-linux/lib/mold /usr/local/lib/
    rm -rf /tmp/mold.tar.gz /tmp/mold-${latest_ver}-x86_64-linux
}
run_step "mold (latest)" install_mold

# Network filesystems
run_step "Network filesystems" sudo apt-get install -y nfs-common cifs-utils

install_starship() {
    command -v starship &>/dev/null && return 0
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
}
run_step "Starship prompt" install_starship

install_zoxide() {
    command -v zoxide &>/dev/null && return 0
    # Prefer apt (Ubuntu 22.04+); fall back to the official installer.
    if sudo apt-get install -y zoxide 2>/dev/null; then
        return 0
    fi
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
        | sh -s -- --bin-dir "$HOME/.local/bin"
}
run_step "zoxide" install_zoxide

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

install_rust() {
    [ -x "$HOME/.cargo/bin/rustup" ] && return 0
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --no-modify-path --default-toolchain stable
}
run_step "Rust toolchain (rustup)" install_rust

install_cargo_crates() {
    local cargo="$HOME/.cargo/bin/cargo"
    [ -x "$cargo" ] || { echo "cargo not found; skipping crates"; return 1; }
    local installed
    installed=$("$cargo" install --list 2>/dev/null | awk '/^[a-zA-Z0-9_-]+ v/ {print $1}')
    for crate in mprocs ytop eza; do
        if printf '%s\n' "$installed" | grep -qx "$crate"; then
            echo "$crate already installed"
        else
            "$cargo" install "$crate" || return 1
        fi
    done
}
run_step "Cargo crates (mprocs, ytop, eza)" install_cargo_crates

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
