#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing CLI tools"

packages=(
    bat
    eza
    expac
    fastfetch
    fd
    fzf
    github-cli
    hwinfo
    jq
    libnotify
    bolt
    tree
    ttf-jetbrains-mono-nerd
    zoxide
    git-delta
)

sudo pacman -S --needed --noconfirm "${packages[@]}"

echo
echo "==> Installed CLI tools:"
for package in "${packages[@]}"; do
    if pacman -Q "$package" &>/dev/null; then
        printf "  ✓ %s\n" "$package"
    else
        printf "  ✗ %s\n" "$package"
    fi
done

echo
echo "CLI setup complete."
