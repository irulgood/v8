#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

ns_domain_cloudflare() {
  DOMAIN="$(cut -d '.' -f2-4 /etc/xray/domain)"
  DOMAIN_PATH="$(cat /etc/xray/domain)"
  SUB="$(cut -d '.' -f1 /etc/xray/domain)"
  SUB_DOMAIN="${SUB}.${DOMAIN}"
  NS_DOMAIN="ns-${SUB_DOMAIN}"
  CF_ID="${CF_ID:-Ridwanstoreaws@gmail.com}"
  CF_KEY="${CF_KEY:-4ecfe9035f4e6e60829e519bd5ee17d66954f}"

  ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active"     -H "X-Auth-Email: ${CF_ID}" -H "X-Auth-Key: ${CF_KEY}" -H "Content-Type: application/json" | jq -r .result[0].id)
  RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}"     -H "X-Auth-Email: ${CF_ID}" -H "X-Auth-Key: ${CF_KEY}" -H "Content-Type: application/json" | jq -r .result[0].id)
  if [ "${#RECORD}" -le 10 ]; then
    RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records"       -H "X-Auth-Email: ${CF_ID}" -H "X-Auth-Key: ${CF_KEY}" -H "Content-Type: application/json"       --data '{"type":"NS","name":"'"${NS_DOMAIN}"'","content":"'"${DOMAIN_PATH}"'","proxied":false}' | jq -r .result.id)
  fi
  curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}"     -H "X-Auth-Email: ${CF_ID}" -H "X-Auth-Key: ${CF_KEY}" -H "Content-Type: application/json"     --data '{"type":"NS","name":"'"${NS_DOMAIN}"'","content":"'"${DOMAIN_PATH}"'","proxied":false}' >/dev/null
  echo "$NS_DOMAIN" > /etc/xray/dns
}

setup_dnstt() {
  mkdir -p /etc/slowdns
  v7_copy_file slowdns/dnstt-server /etc/slowdns/dnstt-server 0755
  v7_copy_file slowdns/dnstt-client /etc/slowdns/dnstt-client 0755
  cd /etc/slowdns
  ./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
  v7_copy_file slowdns/client /etc/systemd/system/client.service 0644
  v7_copy_file slowdns/server /etc/systemd/system/server.service 0644
  sed -i "s/xxxx/${NS_DOMAIN}/g" /etc/systemd/system/client.service /etc/systemd/system/server.service
  systemctl daemon-reload
}

ns_domain_cloudflare
setup_dnstt
