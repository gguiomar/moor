#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${MOOR_INSTALL_DIR:-$HOME/.local/bin}"
IMAGE="moor/cuda:12.8.0-runtime-ubuntu24.04-tmux"

echo "moor installer"
echo "=============="

# 1. Check dependencies
for cmd in docker bash; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is required but not found."; exit 1
  fi
done

# 2. Install the moor script
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/bin/moor" "$INSTALL_DIR/moor"
chmod +x "$INSTALL_DIR/moor"
echo "Installed moor to $INSTALL_DIR/moor"

# 3. Check PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo ""
  echo "NOTE: $INSTALL_DIR is not in your PATH."
  echo "Add this to your ~/.bashrc:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

# 4. Build the Docker image
echo ""
read -rp "Build the Docker image now? [Y/n] " answer
if [[ "${answer:-y}" =~ ^[Yy]$ ]]; then
  echo "Building image '$IMAGE'..."
  docker build -t "$IMAGE" "$SCRIPT_DIR/docker"
  echo "Image '$IMAGE' built successfully."
else
  echo "Skipped. Build it later with:"
  echo "  docker build -t $IMAGE $SCRIPT_DIR/docker"
fi

echo ""
echo "Done! Run 'moor' from any repo directory to start."
