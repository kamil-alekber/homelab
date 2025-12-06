#!/usr/bin/env bash

set -e

# Default values
REMOTE=""
SAVE_PATH=""
REMOTE_PATH="/etc/nixos/*"

# Function to display usage
usage() {
    echo "Usage: $0 --remote <ip_address> --save_path <local_path>"
    echo ""
    echo "Options:"
    echo "  --remote     IP address of the remote NixOS host"
    echo "  --save_path  Local path to save the downloaded files"
    echo ""
    echo "Example:"
    echo "  $0 --remote 192.168.1.82 --save_path ./hosts/k3s-nodes/server-2"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --remote)
            REMOTE="$2"
            shift 2
            ;;
        --save_path)
            SAVE_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required arguments
if [[ -z "$REMOTE" ]]; then
    echo "Error: --remote is required"
    usage
fi

if [[ -z "$SAVE_PATH" ]]; then
    echo "Error: --save_path is required"
    usage
fi

# Create save directory if it doesn't exist
mkdir -p "$SAVE_PATH"

echo "Downloading NixOS configuration from $REMOTE to $SAVE_PATH..."

# Use scp to download files from /etc/nixos/* to save_path
scp -r "root@${REMOTE}:${REMOTE_PATH}" "$SAVE_PATH/"

echo "Successfully downloaded NixOS configuration to $SAVE_PATH"
