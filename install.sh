#!/usr/bin/env bash
set -euo pipefail

: "${DOTFILES_DIR:=$HOME/code/dotfiles}"
export DOTFILES_DIR

if [ ! -e "$DOTFILES_DIR/.git" ]; then
    echo "DOTFILES_DIR=$DOTFILES_DIR is not a git checkout." >&2
    echo "Clone the repo first (see README) and re-run from inside it." >&2
    exit 1
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

echo ""
echo "=== Done! ==="
echo "Log out and back in (or restart WSL) for zsh to take effect."
echo "On first tmux launch, press prefix + I (Ctrl-A then Shift-I) to install plugins via TPM."
echo "Update ~/scripts/jira_config.lua with your JIRA URL for the CopyJiraLink nvim command."
