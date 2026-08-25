#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing fingerprint support"

sudo pacman -S --needed --noconfirm \
    fprintd \
    libfprint \
    usbutils

SUDO_PAM="/etc/pam.d/sudo"
SUDO_PAM_BACKUP="/etc/pam.d/sudo.pre-fingerprint"
FPRINT_AUTH_LINE="auth       sufficient                  pam_fprintd.so"

echo
echo "==> Enabling fingerprint authentication for sudo"

if sudo grep -Eq '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_fprintd\.so([[:space:]]|$)' "$SUDO_PAM"; then
    echo "==> Fingerprint authentication is already enabled for sudo"
else
    if [[ ! -e "$SUDO_PAM_BACKUP" ]]; then
        sudo cp -a -- "$SUDO_PAM" "$SUDO_PAM_BACKUP"
        echo "==> PAM backup created: $SUDO_PAM_BACKUP"
    fi

    pam_tmp="$(mktemp)"
    trap 'rm -f "$pam_tmp"' EXIT

    awk -v fprint_line="$FPRINT_AUTH_LINE" '
        !inserted && /^[[:space:]]*auth[[:space:]]+/ {
            print fprint_line
            inserted = 1
        }
        { print }
        END {
            if (!inserted) {
                exit 1
            }
        }
    ' "$SUDO_PAM" > "$pam_tmp"

    sudo install -o root -g root -m 0644 "$pam_tmp" "$SUDO_PAM"
    echo "==> Fingerprint authentication enabled for sudo"
fi

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
echo
echo "    Test sudo authentication with:"
echo "    sudo -k && sudo -v"
echo
echo "    Password authentication remains available after a failed scan or timeout."
echo "    Restore the previous sudo PAM configuration with:"
echo "    sudo cp -a $SUDO_PAM_BACKUP $SUDO_PAM"
