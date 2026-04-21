#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

systemctl daemon-reload

echo "[INFO] Menyalin file systemd limit klasik..."
v7_copy_file install/limitvmess.service /etc/systemd/system/limitvmess.service 0755
v7_copy_file install/limitvless.service /etc/systemd/system/limitvless.service 0755
v7_copy_file install/limittrojan.service /etc/systemd/system/limittrojan.service 0755

systemctl daemon-reload
systemctl enable --now limitvmess limitvless limittrojan >/dev/null 2>&1 || true
systemctl start limitvmess limitvless limittrojan >/dev/null 2>&1 || true

echo "[INFO] Menyalin script limit-ip template..."
v7_copy_file install/unlockxray /usr/local/sbin/unlockxray 0755
v7_copy_file install/limit-ip /usr/local/sbin/limit-ip 0755
sed -i 's///' /usr/local/sbin/limit-ip

cat > /etc/systemd/system/limit-ip@.service <<'EOF'
[Unit]
Description=Limit-IP AutoLock for %i
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/limit-ip %i
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF

cat > /etc/systemd/system/limit-ip@.timer <<'EOF'
[Unit]
Description=Run limit-ip %i every 1 minute

[Timer]
OnBootSec=30s
OnUnitActiveSec=1min
AccuracySec=10s
Unit=limit-ip@%i.service

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now limit-ip@vmip.timer limit-ip@vlip.timer limit-ip@trip.timer >/dev/null 2>&1 || true

echo "[SUCCESS] Sistem limit service berhasil dipasang dari repo lokal."
