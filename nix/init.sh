#!/bin/sh
set -e

# Set disk variable (adjust as necessary)
DISK=/dev/sda

# Create a new GPT partition table
parted $DISK -- mklabel gpt

# Create a BIOS Boot Partition (1MiB) - type EF02 (required for BIOS mode with GPT)
parted $DISK -- mkpart primary 1MiB 2MiB
parted $DISK -- set 1 bios_grub on

# Create an EFI System Partition (ESP) - 512MiB, type EF00 (vfat)
parted $DISK -- mkpart ESP fat32 2MiB 514MiB
parted $DISK -- set 2 boot on

# Create a Linux swap partition (optional but recommended) - e.g., 8GiB
parted $DISK -- mkpart primary linux-swap 514MiB -8GiB

# Create the main Linux filesystem (root) partition, using the rest of the space
parted $DISK -- mkpart primary ext4 -8GiB 100%

# Verify the partitions
lsblk $DISK


# Format the EFI partition as FAT32
mkfs.fat -F 32 -n EFI_BOOT ${DISK}2

# Format the swap partition and enable it
mkswap -L SWAP ${DISK}3
swapon ${DISK}3

# Format the root partition as ext4 (or btrfs/zfs if your config specifies it)
mkfs.ext4 -L NIXOS_ROOT ${DISK}4

sleep 2

# Mount the root partition to /mnt
mount /dev/disk/by-label/NIXOS_ROOT /mnt

# Create and mount the boot directory
mkdir -p /mnt/boot
mount /dev/disk/by-label/EFI_BOOT /mnt/boot

nixos-generate-config --root /mnt

# mkdir -p /mnt/home/nixos/homelab
# git clone https://github.com/kamil-alekber/homelab.git /mnt/home/nixos/homelab

rm /mnt/etc/nixos/configuration.nix
cp ./hosts/base/configuration.nix /mnt/etc/nixos/configuration.nix

nixos-install

umount -R /mnt
reboot
