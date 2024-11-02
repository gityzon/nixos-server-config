#!/usr/bin/env bash

# 检查是否提供参数
if [ -z "$1" ]; then
  echo "Usage: $0 <hostname>"
  exit 1
fi

HOSTNAME="$1"

echo "Now Going To Build, 🤞"
nixos-generate-config --show-hardware-config >hosts/"$HOSTNAME"/hardware.nix
export NIX_CONFIG="experimental-features = nix-command flakes"
sudo nixos-rebuild switch --flake .#"$HOSTNAME"
