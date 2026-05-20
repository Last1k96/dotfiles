# Dotfiles

Personal Ubuntu development environment.

This repo is the **baseline layer**. It can be installed on its own, or
consumed as a submodule by a machine-specific overlay repo (e.g. a work-VM
overlay that layers proxies, CA certs, work email, and per-machine SSH
keys on top).

## Prerequisites

- Ubuntu 22.04 or newer (WSL works too).
- `sudo` access for system package installs.
- Network access for `apt`, `cargo`, and various upstream release downloads.

## Installation

Standalone (clones into `~/code/dotfiles`):

```bash
curl -fsSL https://raw.githubusercontent.com/Last1k96/dotfiles/main/install.sh | bash
```

Or, from an already-cloned checkout:

```bash
bash install.sh
```

The installer is idempotent — re-running it is safe and is the recommended
way to retry failed steps.

## What gets installed

`scripts/packages.sh` installs:

- Base toolchain: `git`, `git-lfs`, `zsh`, `tmux`, `fzf`, `jq`, `ripgrep`,
  `fd-find`, `bat`, `xclip`, `htop`, `tree`, `mc`, `python3-pip`, `pipx`.
- LLVM 20 + C++ toolchain (`clang`, `clangd`, `lld`, `gdb`, `cmake`,
  `ninja`, `mold`, `valgrind`, `ccache`, `cppcheck`, ...).
- Shell tooling: `zoxide` (smart `cd`), Starship prompt.
- Editor: Neovim (upstream tarball) + LazyVim config.
- Misc: Yazi, Lazygit, tree-sitter CLI, TPM (tmux), Rust + cargo crates
  (`mprocs`, `ytop`, `eza`), NFS/CIFS clients.
- SSH key generation for GitHub.
- Sets `zsh` as the default shell.

`scripts/symlinks.sh` then links the configs in `config/` into `$HOME` /
`$HOME/.config`.

## Post-install

1. **Log out and back in** (or restart WSL) so zsh becomes the active shell.
2. **Tmux plugins** — launch tmux and press `prefix + I` (`Ctrl-A` then
   `Shift-I`) to install plugins via TPM.
3. **JIRA link command** — update `~/scripts/jira_config.lua` with your
   JIRA URL prefix to make the Neovim `:CopyJiraLink` command useful.
4. **SSH key** — add `~/.ssh/id_ed25519.pub` to GitHub at
   <https://github.com/settings/ssh/new>. The installer prints the key.

## Using as a submodule

Overlay repos can add this as a submodule and invoke the baseline install
with a custom `DOTFILES_DIR`:

```bash
DOTFILES_DIR="$PWD/baseline/dotfiles" bash baseline/dotfiles/install.sh
```

The install script honors `DOTFILES_DIR` (env or default
`~/code/dotfiles`) and detects submodule checkouts so it does not try to
re-clone.

## Files

- `install.sh` — entrypoint; chains packages → symlinks.
- `scripts/packages.sh` — apt + upstream tarball + cargo installs.
- `scripts/symlinks.sh` — symlinks `config/` into `$HOME`.
- `config/.zshenv`, `config/.config/zsh/*` — XDG-style zsh config
  (`ZDOTDIR=$HOME/.config/zsh`).
- `config/.gitconfig` — git settings, aliases, SSH signing.
- `config/.tmux.conf` — tmux + TPM plugins.
- `config/.config/starship.toml` — prompt.
- `config/.config/lazyvim/` — LazyVim user config.
