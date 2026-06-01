#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlink() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        ln -sfn "$src" "$dst"
    elif [ -e "$dst" ]; then
        echo "SKIP $dst (exists, not a symlink)"
        return
    else
        ln -s "$src" "$dst"
    fi
    echo "OK   $dst -> $src"
}

# Directory symlinks (~/.config/X -> dotfiles/X)
symlink "$DOTFILES/nvim"                    "$HOME/.config/nvim"

# File symlinks (claude can't use a directory symlink for ~/.claude itself)
symlink "$DOTFILES/claude/keybindings.json" "$HOME/.claude/keybindings.json"
