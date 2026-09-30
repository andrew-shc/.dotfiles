#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlink() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        local current
        current="$(readlink "$dst")"
        if [ "$current" = "$src" ]; then
            echo "OK   $dst -> $src (unchanged)"
        else
            ln -sfn "$src" "$dst"
            echo "UPD  $dst -> $src (was $current)"
        fi
    elif [ -e "$dst" ]; then
        echo "SKIP $dst (exists, not a symlink)"
        return
    else
        ln -s "$src" "$dst"
        echo "NEW  $dst -> $src"
    fi
}

# Directory symlinks (~/.config/X -> dotfiles/X)
symlink "$DOTFILES/nvim"                    "$HOME/.config/nvim"
symlink "$DOTFILES/clangd"                  "$HOME/.config/clangd"

# File symlinks (claude can't use a directory symlink for ~/.claude itself)
symlink "$DOTFILES/claude/keybindings.json" "$HOME/.claude/keybindings.json"

symlink "$DOTFILES/tmux/tmux.conf"  "$HOME/.tmux.conf"
symlink "$DOTFILES/tmux/plugins"    "$HOME/.tmux/plugins"

