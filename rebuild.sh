#!/usr/bin/env bash
# Inspired by https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5

set -e

# Early return if no changes were made since last commit
if git diff --quiet "*.nix"; then
    echo "No changes were made since last commit. Aborting..."
    exit 0
fi

alejandra . &>/dev/null || ( alejandra .; echo "Formatting failed" && exit 1 )

# Shows the changes
git diff -U0 "*.nix"

echo "Starting rebuild..."
sudo nixos-rebuild switch --flake .#${1:-$(hostname -s)} &>result.log || (cat result.log | grep --color error && exit 1)

# Commit changes (with current gen metadata as commit message)
git commit -am "$(nixos-rebuild list-generations 2>/dev/null | grep current)"

echo "New generation built successfully!"
