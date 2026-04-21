#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

loading() {
  local pid="$1"
  local message="$2"
  local delay=0.1
  local spinstr='|/-\'
  tput civis || true
  while kill -0 "$pid" >/dev/null 2>&1; do
    local temp=${spinstr#?}
    printf ' [%c] %s' "$spinstr" "$message"
    spinstr=$temp${spinstr%"$temp"}
    sleep "$delay"
  done
  tput cnorm || true
}

if ! command -v 7z >/dev/null 2>&1; then
  apt-get update -y >/dev/null 2>&1
  apt-get install -y p7zip-full >/dev/null 2>&1 &
  loading $! "Install p7zip-full"
fi

domain="$(cat /etc/xray/domain 2>/dev/null || echo '-')"
MYIP="$(curl -sS ipv4.icanhazip.com || echo '-')"
username="localuser"
valid="4000-12-31"
echo "$username" > /usr/bin/user
echo "$valid" > /usr/bin/e

{
  : > /etc/cron.d/cpu_otm
  cat > /etc/cron.d/cpu_ari <<END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/bin/autocpu
END

  v7_copy_file install/autocpu.sh /usr/bin/autocpu 0755

  tmpdir="$(mktemp -d)"
  unzip -oq "$(v7_repo_path menu/menu.zip)" -d "$tmpdir"
  chmod +x "$tmpdir/menu"/*
  cp -af "$tmpdir/menu/." /usr/local/sbin/
  rm -rf "$tmpdir"

  rm -f /usr/local/sbin/*~ /usr/local/sbin/gz* /usr/local/sbin/*.bak
} >/dev/null 2>&1 &
loading $! "Extract dan setup menu"

if [ -f "$(v7_repo_path versi)" ]; then
  cat "$(v7_repo_path versi)" > /opt/.ver
fi

echo "[INFO] Update menu selesai. Version: $(cat /opt/.ver 2>/dev/null || echo '-')"
echo "[INFO] IP VPS: $MYIP"
echo "[INFO] Domain: $domain"
exit 0
