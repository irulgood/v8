#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="irulgood"
REPO_NAME="v8"
REPO_BRANCH="${1:-main}"
INSTALL_ROOT="/opt/v8-installer"
WORKDIR="$INSTALL_ROOT/work"
CURRENT="$INSTALL_ROOT/current"
ZIPFILE="$WORKDIR/repo.zip"

apt-get update -y >/dev/null 2>&1
apt-get install -y curl unzip ca-certificates >/dev/null 2>&1
mkdir -p "$WORKDIR"
rm -rf "$WORKDIR"/*

ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_BRANCH}.zip"
echo "[INFO] Download repo: $ARCHIVE_URL"
curl -L --fail --silent --show-error "$ARCHIVE_URL" -o "$ZIPFILE"
unzip -oq "$ZIPFILE" -d "$WORKDIR"
EXTRACTED="$(find "$WORKDIR" -maxdepth 2 -type f -name setup.sh | head -n1 | xargs dirname)"
[ -n "$EXTRACTED" ] || { echo "[ERROR] setup.sh tidak ditemukan di archive"; exit 1; }
rm -rf "$CURRENT"
mkdir -p "$INSTALL_ROOT"
cp -a "$EXTRACTED" "$CURRENT"
chmod +x "$CURRENT/setup.sh"
export V7_REPO_DIR="$CURRENT"
bash "$CURRENT/setup.sh"
