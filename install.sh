#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/Last1k96/dotfiles.git"
: "${DOTFILES_DIR:=$HOME/code/dotfiles}"
export DOTFILES_DIR

# If not running from the cloned repo, clone it first.
# `.git` is a directory in a regular checkout and a file in a submodule;
# `-e` covers both.
if [ ! -e "$DOTFILES_DIR/.git" ]; then
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

echo "=== Setting up JIRA config ==="
JIRA_CONFIG="$HOME/scripts/jira_config.lua"
if [ ! -f "$JIRA_CONFIG" ]; then
    mkdir -p "$HOME/scripts"
    cat > "$JIRA_CONFIG" << 'JIRAEOF'
return { prefix = "https://jira.example.com/browse/PROJ-" }
JIRAEOF
    echo "Created example JIRA config at $JIRA_CONFIG"
fi

# Switch remote to SSH now that the SSH key has been generated.
# Skip when this checkout is a submodule (origin is managed by the parent)
# and when origin is already SSH.
if [ -d "$DOTFILES_DIR/.git" ]; then
    current_origin="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
    case "$current_origin" in
        https://github.com/*)
            git -C "$DOTFILES_DIR" remote set-url origin git@github.com:Last1k96/dotfiles.git
            ;;
    esac
fi

echo ""
echo "=== Done! ==="
echo "Log out and back in (or restart WSL) for zsh to take effect."
echo "On first tmux launch, press prefix + I (Ctrl-A then Shift-I) to install plugins via TPM."
echo "Update ~/scripts/jira_config.lua with your JIRA URL for the CopyJiraLink nvim command."
