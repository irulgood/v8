#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

MYIP="$(curl -sS ipv4.icanhazip.com || echo '-')"
username="localuser"
valid="4000-12-31"
echo "$username" > /usr/bin/user
echo "$valid" > /usr/bin/e

serverV="$(cat "$(v7_repo_path versi)" 2>/dev/null || echo 0)"
localV="$(cat /opt/.ver 2>/dev/null || echo 0)"

if [ "$serverV" != "$localV" ]; then
  echo "[INFO] Versi lokal $localV, repo lokal $serverV. Menjalankan update lokal..."
  v7_run_script menu/update.sh
  echo "$serverV" > /opt/.ver
else
  echo "[INFO] Script sudah versi terbaru ($serverV)."
fi

today="$(date +%Y-%m-%d)"
Exp2="$(cat /usr/bin/e 2>/dev/null || echo 4000-12-31)"
d1=$(date -d "$Exp2" +%s)
d2=$(date -d "$today" +%s)
certificate=$(( (d1 - d2) / 86400 ))
echo "$certificate Hari" > /etc/masaaktif
echo "$MYIP" > /etc/myipvps || true
