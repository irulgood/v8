#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

RED='[0;31m'; GREEN='[0;32m'; YELLOW='[0;33m'; BLUE='[0;34m'; CYAN='[0;36m'; NC='[0m'
info(){ echo -e "${CYAN}[INFO]${NC} $*"; }
ok(){ echo -e "${GREEN}[OK]${NC} $*"; }
error(){ echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

clear
echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}   ${GREEN}D£VSX-NETWORK :: Auto Setup Tools${NC}       ${BLUE}║${NC}"
echo -e "${BLUE}╠═══════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}   ⚙️  Installing Rclone, Wondershaper, Limit   ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

info "Installing Rclone..."
apt-get install -y rclone >/dev/null 2>&1 || error "Failed to install Rclone"
printf 'q
' | rclone config >/dev/null 2>&1 || true
v7_copy_file install/rclone.conf /root/.config/rclone/rclone.conf 0644
ok "Rclone installed and configured."

info "Installing Wondershaper..."
rm -rf /tmp/wondershaper
if ! git clone -q https://github.com/casper9/wondershaper.git /tmp/wondershaper; then
  error "Failed to clone wondershaper repo"
fi
cd /tmp/wondershaper
make install >/dev/null 2>&1 || error "Wondershaper install failed"
rm -rf /tmp/wondershaper
ok "Wondershaper installed successfully."

info "Running local limit.sh..."
v7_run_script install/limit.sh
ok "Bandwidth limit configuration applied."

echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ INSTALLATION COMPLETE - ALL SYSTEM READY ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
