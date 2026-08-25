#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scripts=(
    "01-bootstrap.sh"
    "10-cli.sh"
    "20-dev.sh"
    "21-dotnet-workloads.sh"
    "30-apps.sh"
    "31-eimzo.sh"
    "40-config.sh"
)

echo "========================================"
echo " EndeavourOS / Arch workstation setup"
echo "========================================"

for script in "${scripts[@]}"; do
    echo
    echo "========================================"
    echo " Running: $script"
    echo "========================================"

    "$SCRIPT_DIR/$script"
done

echo
echo "========================================"
echo " Base setup complete"
echo "========================================"
echo
echo "Personal SSH keys, private repositories, and private configuration"
echo "belong in a separate private setup repository."
