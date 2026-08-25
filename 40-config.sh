#!/usr/bin/env bash
set -euo pipefail

FISH_CONF_DIR="$HOME/.config/fish"
FISH_CONF="$FISH_CONF_DIR/config.fish"

SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SSH_AGENT_SERVICE="$SYSTEMD_USER_DIR/ssh-agent.service"

echo "========================================"
echo " User configuration setup"
echo "========================================"

if ! command -v fish &>/dev/null; then
    echo "ERROR: Fish is not installed."
    echo "Run 01-bootstrap.sh first."
    exit 1
fi

#
# Fish configuration
#

echo
echo "==> Configuring Fish"

mkdir -p "$FISH_CONF_DIR"

cat > "$FISH_CONF" <<'EOF'
#
# User Fish configuration
#

#
# zoxide
#

if type -q zoxide
    zoxide init fish | source
end


#
# Useful aliases
#

if type -q eza
    alias ll='eza -lah'
    alias la='eza -a'
    alias l='eza -lah'
end

if type -q bat
    alias cat='bat'
end


#
# Preferred command-line editor
#

if type -q nano
    set -gx EDITOR nano
    set -gx VISUAL nano
end


#
# SSH agent
#

set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
EOF

echo "==> Fish configuration created:"
echo "    $FISH_CONF"

echo
echo "==> Configuring Fish as the default shell"

FISH_PATH="$(command -v fish)"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$FISH_PATH" ]]; then
    echo "==> Fish is already the default shell"
else
    chsh -s "$FISH_PATH"
    echo "==> Default shell changed to: $FISH_PATH"
    echo "    Log out and back in for the change to take effect."
fi

#
# SSH agent
#

echo
echo "==> Configuring SSH agent"

mkdir -p "$SYSTEMD_USER_DIR"

cat > "$SSH_AGENT_SERVICE" <<'EOF'
[Unit]
Description=SSH authentication agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a %t/ssh-agent.socket

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now ssh-agent.service

echo "==> SSH agent enabled"

#
# Plasma keyboard layout shortcut
#

echo
echo "==> Configuring Alt+Shift keyboard layout switching"

if command -v kwriteconfig6 &>/dev/null; then
    kwriteconfig6 \
        --file kxkbrc \
        --group Layout \
        --key Options \
        "grp:alt_shift_toggle"

    echo "==> Alt+Shift configured"
    echo "    Logout/login may be required."
else
    echo "WARNING: kwriteconfig6 not found"
    echo "         Keyboard shortcut was not changed."
fi

#
# Done
#

echo
echo "========================================"
echo " User configuration complete"
echo "========================================"

echo
echo "Fish config:"
echo "  $FISH_CONF"

echo "Default shell:"
echo "  $(getent passwd "$USER" | cut -d: -f7)"

echo
echo "SSH agent:"
echo "  systemctl --user status ssh-agent.service"

echo
echo "SSH agent socket:"
echo "  $XDG_RUNTIME_DIR/ssh-agent.socket"

echo
echo "If this terminal was already open before running this script,"
echo "reload the Fish configuration with:"
echo
echo "  source $FISH_CONF"
echo
