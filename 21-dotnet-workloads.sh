#!/usr/bin/env bash
set -euo pipefail

echo "==> Updating .NET workloads"
sudo dotnet workload update

echo
echo "==> Installing WebAssembly workloads"
sudo dotnet workload install wasm-tools wasm-tools-net8

echo
echo "==> Configuring ASP.NET Core development HTTPS certificate"

mkdir -p "$HOME/.aspnet/dev-certs/trust"

# Trust directory for OpenSSL in the current script
export SSL_CERT_DIR="$HOME/.aspnet/dev-certs/trust:/etc/ssl/certs"

# Persist it for Fish
if command -v fish &>/dev/null; then
    fish -c 'set -Ux SSL_CERT_DIR "$HOME/.aspnet/dev-certs/trust:/etc/ssl/certs"'
fi

echo
echo "==> Recreating and trusting development HTTPS certificate"
dotnet dev-certs https --clean
dotnet dev-certs https --trust

echo
echo "==> Checking HTTPS development certificate"
dotnet dev-certs https --check --trust

echo
echo "==> Installed .NET workloads"
dotnet workload list

echo
echo "==> .NET workloads setup complete"