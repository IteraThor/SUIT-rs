#!/usr/bin/env bash
set -e

echo "========================================="
echo "   SUIT for Fedora (Rust) - Automated Setup"
echo "========================================="

if [ ! -f /etc/fedora-release ]; then
    echo "Warning: /etc/fedora-release not detected. SUIT is optimized for Fedora Linux."
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Build and runtime dependencies via DNF
echo "[1/4] Installing system packages..."
sudo dnf install -y --setopt=install_weak_deps=False \
    cargo rust \
    gtk4-devel libadwaita-devel vte291-gtk4-devel \
    opencv-devel clang-devel \
    v4l-utils pipewire-utils git

# 2. Build the release binary
echo "[2/4] Building SUIT (this takes a few minutes the first time)..."
(cd "${SCRIPT_DIR}" && cargo build --release)
chmod +x "${SCRIPT_DIR}/suit-launch.sh"

# 3. Application and desktop launchers
echo "[3/4] Generating desktop and menu launchers..."
"${SCRIPT_DIR}/target/release/suit" create-launcher

# 4. Display & touch autostart and the switchable shell extensions (disabled, discovered at next login)
if [ -f "$HOME/.suit_rotation_config.json" ]; then
    echo "  - Synchronizing display & touch autostart..."
    "${SCRIPT_DIR}/target/release/suit" ensure-autostart || \
        echo "  ! Warning: could not synchronize display autostart. Launch SUIT once to retry automatically."
fi
"${SCRIPT_DIR}/target/release/suit" install-extensions || \
    echo "  ! Warning: could not pre-install the SUIT shell extensions. Launch SUIT once to retry automatically."

echo "[4/4] Installation completed successfully!"
echo "========================================="
echo "SUIT is now installed and ready to use."
echo "Launch SUIT from your application menu or Dash favorites."
echo "========================================="
