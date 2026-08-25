#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing fingerprint support"

sudo pacman -S --needed --noconfirm \
    fprintd \
    libfprint \
    usbutils

echo
echo "==> Looking for a fingerprint reader"

if lsusb | grep -Eiq 'fingerprint|synaptics.*06cb:00f9|06cb:00f9'; then
    echo "==> Fingerprint reader detected"
else
    echo "WARNING: No supported fingerprint reader was detected by lsusb."
    echo "         Check that the reader is enabled in UEFI/BIOS."
fi

echo
echo "==> Fingerprint packages installed"
echo "    Fingerprints are tied to the reader and must be enrolled on this machine."
echo "    In KDE Plasma open:"
echo "    System Settings -> Users -> Configure Fingerprint Authentication"
echo
echo "    Or enroll from a terminal with:"
echo "    fprintd-enroll"
echo
echo "    Verify the enrolled fingerprint with:"
echo "    fprintd-verify"
