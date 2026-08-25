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

if not status is-interactive
    return
end

# CachyOS-style welcome screen
function fish_greeting
    if type -q fastfetch
        fastfetch
    end
end

# User executable directories
fish_add_path "$HOME/.local/bin" "$HOME/.cargo/bin"

# Better man pages
if type -q bat
    set -gx MANROFFOPT -c
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

# Directory jumping and fuzzy history/file search
if type -q zoxide
    zoxide init fish | source
end

if type -q fzf
    fzf --fish | source
end

#
# Useful aliases
#

if type -q eza
    alias ls='eza -al --color=always --group-directories-first --icons=always'
    alias la='eza -a --color=always --group-directories-first --icons=always'
    alias ll='eza -l --color=always --group-directories-first --icons=always'
    alias lt='eza -aT --color=always --group-directories-first --icons=always'
    alias l.='eza -a | grep -E "^\."'
end

if type -q bat
    alias cat='bat'
end

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias grep='grep --color=auto'
alias update='yay -Syu'
alias jctl='journalctl -p 3 -xb'
alias gitpkg='pacman -Q | grep -i -- "-git" | count'

if type -q expac
    alias big='expac -H M "%m\t%n" | sort -h | nl'
    alias rip='expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'
end

# Timestamped command history
function history
    builtin history --show-time='%F %T ' $argv
end

# Quick file backup
function backup --argument-names filename
    if test -z "$filename"
        echo 'Usage: backup FILE' >&2
        return 2
    end

    command cp -- "$filename" "$filename.bak"
end

# Copy directories recursively while keeping normal cp behaviour for files
function copy
    if test (count $argv) -eq 2; and test -d "$argv[1]"
        command cp -r -- (string trim --right --chars=/ "$argv[1]") "$argv[2]"
    else
        command cp -- $argv
    end
end

# Bash-style !! and !$ history expansion while typing
function __history_previous_command
    switch (commandline -t)
        case '!'
            commandline -t $history[1]
            commandline -f repaint
        case '*'
            commandline -i '!'
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case '!'
            commandline -t ''
            commandline -f history-token-search-backward
        case '*'
            commandline -i '$'
    end
end

if test "$fish_key_bindings" = fish_vi_key_bindings
    bind -M insert ! __history_previous_command
    bind -M insert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
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
