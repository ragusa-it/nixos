#!/usr/bin/env bash
# NixOS Installation Script - Full Disk Encryption with Limine
# Target: /dev/nvme0n1
# Layout: 1GB EFI + 34GB encrypted swap + remaining encrypted root
# Filesystems: FAT32 (EFI), XFS (root), swap

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════
DISK="/dev/nvme0n1"
EFI_PART="${DISK}p1"
SWAP_PART="${DISK}p2"
ROOT_PART="${DISK}p3"

EFI_SIZE="1GiB"
SWAP_SIZE="35GiB"  # 1GiB + 34GiB = 35GiB end point

# ═══════════════════════════════════════════════════════════════
# SAFETY CHECK
# ═══════════════════════════════════════════════════════════════
echo "WARNING: This will DESTROY all data on ${DISK}"
echo ""
echo "Partition layout:"
echo "  ${EFI_PART}  - 1GB   EFI System Partition (FAT32)"
echo "  ${SWAP_PART} - 34GB  Encrypted swap (LUKS2)"
echo "  ${ROOT_PART} - Rest  Encrypted root (LUKS2 + XFS)"
echo ""
read -p "Type 'YES' to continue: " confirm

if [[ "$confirm" != "YES" ]]; then
    echo "Aborted."
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# PHASE 1: PARTITIONING
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ Phase 1: Partitioning ${DISK} ═══"

parted "${DISK}" -- mklabel gpt
parted "${DISK}" -- mkpart ESP fat32 1MiB "${EFI_SIZE}"
parted "${DISK}" -- set 1 esp on
parted "${DISK}" -- mkpart swap "${EFI_SIZE}" "${SWAP_SIZE}"
parted "${DISK}" -- mkpart root "${SWAP_SIZE}" 100%

echo "Partitioning complete."
sleep 1

# ═══════════════════════════════════════════════════════════════
# PHASE 2: FORMAT EFI
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ Phase 2: Formatting EFI partition ═══"

mkfs.fat -F 32 -n BOOT "${EFI_PART}"

echo "EFI partition formatted."

# ═══════════════════════════════════════════════════════════════
# PHASE 3: LUKS ENCRYPTION
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ Phase 3: Setting up LUKS encryption ═══"

echo ""
echo "─── Encrypting ROOT partition (${ROOT_PART}) ───"
echo "You will be prompted to create a passphrase."
cryptsetup luksFormat --type luks2 --label cryptroot "${ROOT_PART}"
cryptsetup open "${ROOT_PART}" cryptroot

echo ""
echo "─── Encrypting SWAP partition (${SWAP_PART}) ───"
echo "You will be prompted to create a passphrase (can be same as root)."
cryptsetup luksFormat --type luks2 --label cryptswap "${SWAP_PART}"
cryptsetup open "${SWAP_PART}" cryptswap

echo "LUKS encryption configured."

# ═══════════════════════════════════════════════════════════════
# PHASE 4: GENERATE SWAP KEYFILE
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ Phase 4: Generating swap keyfile ═══"

dd bs=4096 count=1 if=/dev/urandom of=/tmp/swap.key iflag=fullblock
chmod 600 /tmp/swap.key

echo "Adding keyfile to swap LUKS volume..."
cryptsetup luksAddKey "${SWAP_PART}" /tmp/swap.key

echo "Keyfile generated and added to swap."

# ═══════════════════════════════════════════════════════════════
# PHASE 5: FORMAT ENCRYPTED VOLUMES
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ Phase 5: Formatting encrypted volumes ═══"

mkfs.xfs -L nixos /dev/mapper/cryptroot
mkswap -L swap /dev/mapper/cryptswap

echo "Filesystems created."

# ═══════════════════════════════════════════════════════════════
# PHASE 6: MOUNT
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ Phase 6: Mounting filesystems ═══"

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/var/lib/secrets
mount "${EFI_PART}" /mnt/boot
swapon /dev/mapper/cryptswap

# Store keyfile securely
mv /tmp/swap.key /mnt/var/lib/secrets/swap.key
chmod 600 /mnt/var/lib/secrets/swap.key
chown root:root /mnt/var/lib/secrets/swap.key

echo "Filesystems mounted."
echo ""
echo "Mount layout:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT "${DISK}"

# ═══════════════════════════════════════════════════════════════
# PHASE 7: GENERATE HARDWARE CONFIG
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ Phase 7: Generating NixOS hardware configuration ═══"

nixos-generate-config --root /mnt

echo "Hardware configuration generated at /mnt/etc/nixos/"

# ═══════════════════════════════════════════════════════════════
# NEXT STEPS
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DISK SETUP COMPLETE!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "1. Copy your NixOS configuration to /mnt/etc/nixos/"
echo "   Example: cp -r ~/nixos/* /mnt/etc/nixos/"
echo ""
echo "2. IMPORTANT: Verify hardware-configuration.nix has correct mounts:"
echo "   - fileSystems.\"/\" = { device = \"/dev/mapper/cryptroot\"; fsType = \"xfs\"; }"
echo "   - fileSystems.\"/boot\" = { device = \"/dev/disk/by-label/BOOT\"; fsType = \"vfat\"; }"
echo "   - swapDevices = [ { device = \"/dev/mapper/cryptswap\"; } ]"
echo ""
echo "3. Run the installation:"
echo "   nixos-install --flake /mnt/etc/nixos#nixos"
echo ""
echo "4. After reboot, run the Secure Boot setup script."
echo ""
