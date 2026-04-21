#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

echo "✨ FILE ENC BY ANSENDANTVPN"
export DEBIAN_FRONTEND=noninteractive
MYIP="$(wget -qO- ipinfo.io/ip)"
MYIP2="s/xxxxxxxxx/$MYIP/g"
ANU="$(ip -o -4 route show to default | awk '{print $5}' | head -n1)"

apt-get install -y openvpn easy-rsa unzip openssl iptables iptables-persistent >/dev/null 2>&1
mkdir -p /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/
unzip -oq "$(v7_repo_path install/vpn.zip)"
chown -R root:root /etc/openvpn/server/easy-rsa/
mkdir -p /usr/lib/openvpn/
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so || true
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
systemctl enable --now openvpn-server@server-tcp >/dev/null 2>&1 || true
systemctl enable --now openvpn-server@server-udp >/dev/null 2>&1 || true
/etc/init.d/openvpn restart || true

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

cat > /etc/openvpn/tcp.ovpn <<END
client
dev tun
proto tcp
remote xxxxxxxxx 1194
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
sed -i "$MYIP2" /etc/openvpn/tcp.ovpn

cat > /etc/openvpn/udp.ovpn <<END
client
dev tun
proto udp
remote xxxxxxxxx 2200
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
sed -i "$MYIP2" /etc/openvpn/udp.ovpn

cat > /etc/openvpn/ssl.ovpn <<END
client
dev tun
proto tcp
remote xxxxxxxxx 990
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END
sed -i "$MYIP2" /etc/openvpn/ssl.ovpn

/etc/init.d/openvpn restart || true
for f in tcp udp ssl; do
  echo '<ca>' >> "/etc/openvpn/${f}.ovpn"
  cat /etc/openvpn/server/ca.crt >> "/etc/openvpn/${f}.ovpn"
  echo '</ca>' >> "/etc/openvpn/${f}.ovpn"
  cp "/etc/openvpn/${f}.ovpn" "/home/vps/public_html/${f}.ovpn"
done

iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o "$ANU" -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o "$ANU" -j MASQUERADE
iptables-save > /etc/iptables.up.rules
chmod +x /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save || true
netfilter-persistent reload || true
systemctl enable openvpn >/dev/null 2>&1 || true
systemctl start openvpn >/dev/null 2>&1 || true
