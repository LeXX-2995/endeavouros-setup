#!/usr/bin/env bash
set -euo pipefail

echo "==> Updating system"
sudo pacman -Syu --noconfirm

echo
echo "==> Installing base packages"

base_packages=(
    base-devel
    fish
    git
    bluez 
    bluez-utils
    nano
    openssh
)

sudo pacman -S --needed --noconfirm "${base_packages[@]}"

echo
echo "==> Checking yay"

if command -v yay &>/dev/null; then
    echo "==> yay is already installed"
elif pacman -Si yay &>/dev/null; then
    echo "==> Installing yay from a configured repository"
    sudo pacman -S --needed --noconfirm yay
else
    echo "==> yay was not found in the configured repositories"
    echo "==> Installing yay-bin from AUR"

    yay_build_dir="$(mktemp -d)"
    trap 'rm -rf "$yay_build_dir"' EXIT

    git clone https://aur.archlinux.org/yay-bin.git "$yay_build_dir/yay-bin"
    (
        cd "$yay_build_dir/yay-bin"
        makepkg -si --needed --noconfirm
    )
fi

echo "Enabling Bluetooth"
sudo systemctl enable --now bluetooth.service
echo
echo "==> Bootstrap complete"
