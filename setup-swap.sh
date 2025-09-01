#!/bin/bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root or with sudo"
  exit 1
fi

target_swap_mb="${1:-2048}"

current_swap_mb=$(free -m | awk '/Swap/ {print $2}')
echo "Current swap: ${current_swap_mb}MB"
echo "Target swap: ${target_swap_mb}MB"

if [[ "$current_swap_mb" -ge "$target_swap_mb" ]]; then
  echo "Swap is sufficient (${current_swap_mb}MB >= ${target_swap_mb}MB)"
  exit 0
fi

additional_swap_mb=$((target_swap_mb - current_swap_mb))
echo "Adding ${additional_swap_mb}MB of swap..."

swapfile="/swapfile"
counter=1
while [[ -f "$swapfile" ]]; do
  counter=$((counter + 1))
  swapfile="/swapfile${counter}"
done

echo "Creating ${swapfile} with ${additional_swap_mb}MB..."

dd if=/dev/zero of="$swapfile" bs=1M count="$additional_swap_mb" status=progress
chmod 600 "$swapfile"
mkswap "$swapfile"
swapon "$swapfile"

grep -q "$swapfile" /etc/fstab || echo "$swapfile none swap sw 0 0" >>/etc/fstab

echo "Swap setup complete:"
free -h | grep Swap
