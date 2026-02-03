#!/usr/bin/env bash
# Secure Boot Setup Script for NixOS with Limine
# Run this AFTER first successful boot into NixOS

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════"
echo "  NixOS Secure Boot Setup"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════
# CHECK PREREQUISITES
# ═══════════════════════════════════════════════════════════════
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

if ! command -v sbctl &> /dev/null; then
    echo "ERROR: sbctl not found. Ensure your NixOS config includes it."
    echo "Add to configuration.nix: environment.systemPackages = [ pkgs.sbctl ];"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════
# STEP 1: CHECK CURRENT STATUS
# ═══════════════════════════════════════════════════════════════
echo "─── Step 1: Checking current Secure Boot status ───"
echo ""

sbctl status || true
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 2: CREATE SECURE BOOT KEYS
# ═══════════════════════════════════════════════════════════════
echo "─── Step 2: Creating Secure Boot keys ───"
echo ""

if [[ -d /etc/secureboot/keys ]]; then
    echo "Keys already exist at /etc/secureboot/keys"
    read -p "Regenerate keys? (y/N): " regen
    if [[ "$regen" == "y" || "$regen" == "Y" ]]; then
        sbctl create-keys
    fi
else
    sbctl create-keys
fi

echo ""
echo "Keys created successfully."

# ═══════════════════════════════════════════════════════════════
# STEP 3: VERIFY WHAT NEEDS SIGNING
# ═══════════════════════════════════════════════════════════════
echo ""
echo "─── Step 3: Checking files that need signing ───"
echo ""

sbctl verify

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 4: ENROLL KEYS
# ═══════════════════════════════════════════════════════════════
echo ""
echo "─── Step 4: Enrolling Secure Boot keys ───"
echo ""
echo "IMPORTANT: Before this step, you must:"
echo "  1. Reboot into UEFI/BIOS settings"
echo "  2. Find Secure Boot settings"
echo "  3. Clear existing keys OR put Secure Boot in 'Setup Mode'"
echo "  4. Save and boot back to NixOS"
echo ""
read -p "Have you put Secure Boot in Setup Mode? (y/N): " setup_mode

if [[ "$setup_mode" != "y" && "$setup_mode" != "Y" ]]; then
    echo ""
    echo "Please reboot into UEFI and enable Setup Mode first."
    echo "Then run this script again."
    exit 0
fi

echo ""
echo "Enrolling keys with Microsoft keys included (for hardware compatibility)..."
sbctl enroll-keys -m

echo ""
echo "Keys enrolled successfully."

# ═══════════════════════════════════════════════════════════════
# STEP 5: REBUILD NIXOS TO SIGN EVERYTHING
# ═══════════════════════════════════════════════════════════════
echo ""
echo "─── Step 5: Rebuilding NixOS to sign bootloader and kernel ───"
echo ""

nixos-rebuild switch --flake ~/nixos#nixos

echo ""
echo "NixOS rebuilt with signed binaries."

# ═══════════════════════════════════════════════════════════════
# STEP 6: FINAL VERIFICATION
# ═══════════════════════════════════════════════════════════════
echo ""
echo "─── Step 6: Final verification ───"
echo ""

sbctl verify

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  SECURE BOOT SETUP COMPLETE!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Reboot into UEFI/BIOS"
echo "  2. Enable Secure Boot"
echo "  3. Save and boot"
echo ""
echo "After reboot, verify with: sbctl status"
echo ""
