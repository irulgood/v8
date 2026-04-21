#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

file_path="/etc/handeling"
if [ ! -s "$file_path" ]; then
  printf 'AnsendantVpn Server Connected
BLUE
' > "$file_path"
fi

apt-get install -y python3 >/dev/null 2>&1
v7_copy_file sshws/ws /usr/bin/ws 0755
v7_copy_file sshws/config.conf /usr/bin/config.conf 0644
v7_copy_file sshws/ws /usr/local/bin/ws-ovpn 0755

cat > /etc/systemd/system/ws.service <<'END'
[Unit]
Description=Proxy Mod By Newbie Store
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/ws -f /usr/bin/config.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

cat > /etc/systemd/system/ws-ovpn.service <<'END'
[Unit]
Description=Proxy Mod By NEWBIE STORE
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/ws-ovpn 2086
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable --now ws.service ws-ovpn.service >/dev/null 2>&1 || true
