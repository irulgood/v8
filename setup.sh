#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$SCRIPT_DIR}"

write_local_repo_helper() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  cat > "$target" <<'EOF'
#!/usr/bin/env bash
set +u

v7_resolve_repo_dir() {
  if [ -n "${V7_REPO_DIR:-}" ] && [ -d "${V7_REPO_DIR}" ]; then
    printf '%s\n' "$V7_REPO_DIR"
    return 0
  fi

  local src dir
  src="${1:-${BASH_SOURCE[0]}}"
  dir="$(cd "$(dirname "$src")" && pwd)"

  while [ "$dir" != "/" ]; do
    if [ -f "$dir/setup.sh" ] && [ -d "$dir/install" ]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  pwd
}

V7_REPO_DIR="$(v7_resolve_repo_dir "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")"
export V7_REPO_DIR

v7_repo_path() {
  printf '%s\n' "$V7_REPO_DIR/$1"
}

v7_require_file() {
  local src
  src="$(v7_repo_path "$1")"
  [ -f "$src" ] || {
    echo "[ERROR] File repo tidak ditemukan: $1" >&2
    return 1
  }
}

v7_copy_file() {
  local rel="$1"
  local dest="$2"
  local mode="${3:-0644}"
  local src
  src="$(v7_repo_path "$rel")"
  [ -f "$src" ] || {
    echo "[ERROR] File repo tidak ditemukan: $rel" >&2
    return 1
  }
  install -D -m "$mode" "$src" "$dest"
}

v7_run_script() {
  local rel="$1"
  shift || true
  local src
  src="$(v7_repo_path "$rel")"
  [ -f "$src" ] || {
    echo "[ERROR] Script repo tidak ditemukan: $rel" >&2
    return 1
  }
  chmod +x "$src"
  bash "$src" "$@"
}

v7_unzip_to() {
  local rel="$1"
  local dest="$2"
  local src
  src="$(v7_repo_path "$rel")"
  [ -f "$src" ] || {
    echo "[ERROR] Arsip repo tidak ditemukan: $rel" >&2
    return 1
  }
  mkdir -p "$dest"
  unzip -oq "$src" -d "$dest"
}

v7_try_copy_or_fetch() {
  local rel="$1"
  local dest="$2"
  local mode="${3:-0644}"
  local remote_base="${4:-}"
  local src
  src="$(v7_repo_path "$rel")"
  if [ -f "$src" ]; then
    install -D -m "$mode" "$src" "$dest"
    return 0
  fi
  if [ -n "$remote_base" ]; then
    wget -q -O "$dest" "${remote_base%/}/$rel" && chmod "$mode" "$dest"
    return $?
  fi
  echo "[ERROR] Gagal mendapatkan file: $rel" >&2
  return 1
}
EOF
  chmod +x "$target"
}

if [ ! -f "$V7_REPO_DIR/lib/local_repo.sh" ]; then
  echo "[WARN] lib/local_repo.sh tidak ditemukan, membuat helper fallback..."
  write_local_repo_helper "$V7_REPO_DIR/lib/local_repo.sh"
fi
# shellcheck source=lib/local_repo.sh
. "$V7_REPO_DIR/lib/local_repo.sh"

# Nonaktifkan IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true

# SET MANUAL (tanpa GitHub)
username="localuser"
valid="4000-12-31"
echo "$username" > /usr/bin/user
echo "$valid" > /usr/bin/e

red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\033[0m'
bold_white="\e[1;37m"
yellow='\e[38;5;226m'
gray='\e[38;5;245m'

secs_to_human() {
  echo "Waktu instalasi : $(( $1 / 3600 )) jam $(( ($1 / 60) % 60 )) menit $(( $1 % 60 )) detik"
}

fun_bar() {
  local label="$1"
  shift
  (
    "$@" >/tmp/v7-step.log 2>&1
    echo $? > /tmp/v7-step.rc
  ) &
  local pid=$!
  tput civis || true
  echo -ne "  ${bold_white}🔄 ${label} ${green}["
  while kill -0 "$pid" >/dev/null 2>&1; do
    echo -ne "#"
    sleep 0.1
  done
  wait "$pid" || true
  tput cnorm || true
  if [ -f /tmp/v7-step.rc ] && [ "$(cat /tmp/v7-step.rc)" = "0" ]; then
    echo -e "] ${green}✅ Sukses${NC}"
  else
    echo -e "] ${red}❌ Gagal${NC}"
    [ -f /tmp/v7-step.log ] && tail -n 40 /tmp/v7-step.log
    exit 1
  fi
  rm -f /tmp/v7-step.rc /tmp/v7-step.log
}

prepare_domain_files() {
  local dn="$1"
  rm -rf /etc/v2ray /etc/nsdomain /etc/per
  mkdir -p /etc/xray /etc/v2ray /etc/nsdomain /var/lib
  : > /etc/xray/domain
  : > /etc/v2ray/domain
  : > /etc/xray/slwdomain
  : > /etc/v2ray/scdomain
  echo "$dn" > /root/domain
  echo "$dn" > /root/scdomain
  echo "$dn" > /etc/xray/scdomain
  echo "$dn" > /etc/v2ray/scdomain
  echo "$dn" > /etc/xray/domain
  echo "$dn" > /etc/v2ray/domain
  echo "IP=$dn" > /var/lib/ipvps.conf
}

setup_domain() {
  clear
  echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${bold_white}              🎯 SETUP DOMAIN VPS              ${NC}"
  echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${yell}------------------------------------------------${NC}"
  echo -e "${green} 1. ${bold_white}Gunakan Domain Sendiri${NC}"
  echo -e "${green} 2. ${bold_white}Gunakan Domain Random via Cloudflare${NC}"
  echo -e "${yell}------------------------------------------------${NC}"

  local choice=""
  while ! [[ "$choice" =~ ^[12]$ ]]; do
    read -r -p "   Pilih opsi 1 atau 2 : " choice
  done

  if [ "$choice" = "1" ]; then
    local dnss=""
    while ! [[ "$dnss" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
      read -r -p "🌐 Masukkan domain Anda: " dnss
    done
    prepare_domain_files "$dnss"
    clear
    return 0
  fi

  echo -e "${green}┌──────────────────────────────────────────┐${NC}"
  echo -e "${green}│  ${bold_white}Contoh: ${gray}free${NC}                            ${green}│${NC}"
  echo -e "${green}│  ${bold_white}Akan menjadi: ${gray}free.myrid.web.id${NC}                  ${green}│${NC}"
  echo -e "${green}└──────────────────────────────────────────┘${NC}"
  echo

  if [ -n "${CF_ID:-}" ] && [ -n "${CF_KEY:-}" ]; then
    echo -e "${yellow}CF_ID dan CF_KEY terdeteksi, menjalankan auto pointing.${NC}"
    fun_bar "Update domain random" v7_run_script install/pointing.sh
    return 0
  fi

  local sub=""
  while ! [[ "$sub" =~ ^[a-zA-Z0-9_.-]+$ ]]; do
    read -r -p "🌐 Masukkan subdomain (tanpa spasi): " sub
  done
  echo -e "${yellow}Catatan:${NC} pointing DNS Cloudflare tidak dijalankan karena CF_ID/CF_KEY belum diset."
  prepare_domain_files "$sub"
  clear
}

run_api_installer() {
  if [ -f "$(v7_repo_path 'api/install-api.sh')" ]; then
    v7_run_script api/install-api.sh
  else
    echo "[WARN] Installer API lokal tidak ditemukan, dilewati."
  fi
}

install_stage() {
  local label="$1"
  local rel="$2"
  echo -e "${green}┌──────────────────────────────────────────┐${NC}"
  printf "%b│ %-40s │%b\n" "$green" "$label" "$NC"
  echo -e "${green}└──────────────────────────────────────────┘${NC}"
  fun_bar "$label" v7_run_script "$rel"
}

Pasang() {
  start=$(date +%s)
  export start
  ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
  fun_bar "Install dependency dasar" v7_run_script tools.sh
  apt-get update -y >/dev/null 2>&1
  apt-get install -y git curl python-is-python3 unzip >/dev/null 2>&1
}

Installasi() {
  local os_id os_name
  os_id="$(. /etc/os-release && echo "$ID")"
  os_name="$(. /etc/os-release && echo "$PRETTY_NAME")"

  case "$os_id" in
    ubuntu|debian|kali)
      echo -e "${green}Setup installer untuk OS $os_name${NC}"
      ;;
    *)
      echo -e "OS Anda Tidak Didukung (${yell}$os_name${NC})"
      exit 1
      ;;
  esac

  install_stage "MEMASANG SSH & OPENVPN" install/ssh-vpn.sh
  install_stage "MEMASANG XRAY" install/ins-xray.sh
  install_stage "MEMASANG WEBSOCKET SSH" sshws/insshws.sh
  install_stage "MEMASANG MENU BACKUP" install/set-br.sh
  install_stage "MEMASANG OHP" sshws/ohp.sh
  install_stage "MEMASANG MENU EKSTRA" menu/update.sh
  install_stage "MEMASANG SLOWDNS" slowdns/installsl.sh
  install_stage "MEMASANG UDP CUSTOM" install/udp-custom.sh
  install_stage "MEMASANG DROPBEAR-2019" install/dropbear2019
  echo -e "${green}┌──────────────────────────────────────────┐${NC}"
  printf "%b│ %-40s │%b\n" "$green" "MEMASANG API LOKAL" "$NC"
  echo -e "${green}└──────────────────────────────────────────┘${NC}"
  fun_bar "Pasang API lokal" run_api_installer
}

iinfo() {
  local domain CHATID KEY URL ISP CITY TIME RAMMS MODEL2 MYIP
  domain="$(cat /etc/xray/domain 2>/dev/null || echo '-')"
  CHATID="${CHATID_TELEGRAM:-ID_TELE}"
  KEY="${TOKEN_TELEGRAM:-TOKEN_TELE}"
  [ "$CHATID" = "ID_TELE" ] || [ "$KEY" = "TOKEN_TELE" ] || {
    URL="https://api.telegram.org/bot$KEY/sendMessage"
    ISP="$(cat /etc/xray/isp 2>/dev/null || echo '-')"
    CITY="$(cat /etc/xray/city 2>/dev/null || echo '-')"
    TIME="$(date +'%Y-%m-%d %H:%M:%S')"
    RAMMS="$(free -m | awk 'NR==2 {print $2}')"
    MODEL2="$(grep -w PRETTY_NAME /etc/os-release | head -n1 | cut -d= -f2 | tr -d '"')"
    MYIP="$(curl -sS ipv4.icanhazip.com || echo '-')"
    local TEXT
    TEXT="
<code>━━━━━━━━━━━━━━━━━━━━</code>
<code>⚠️ AUTOSCRIPT PREMIUM ⚠️</code>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<code>NAMA : </code><code>${author}</code>
<code>WAKTU : </code><code>${TIME} WIB</code>
<code>DOMAIN : </code><code>${domain}</code>
<code>IP : </code><code>${MYIP}</code>
<code>ISP : </code><code>${ISP} ${CITY}</code>
<code>OS LINUX : </code><code>${MODEL2}</code>
<code>RAM : </code><code>${RAMMS} MB</code>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<i> Notifikasi Installer Script...</i>"
    curl -s --max-time 10 -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" "$URL" >/dev/null || true
  }
}

if [ "${EUID}" -ne 0 ]; then
  echo "Anda perlu menjalankan script ini sebagai root"
  exit 1
fi

if [ "$(systemd-detect-virt)" = "openvz" ]; then
  echo "OpenVZ tidak didukung"
  exit 1
fi

localip="$(hostname -I | awk '{print $1}')"
hst="$(hostname)"
dart="$(grep -w "$(hostname)" /etc/hosts | awk '{print $2}' | head -n1 || true)"
if [ "$hst" != "$dart" ]; then
  echo "$localip $(hostname)" >> /etc/hosts
fi

mkdir -p /etc/xray /var/lib >/dev/null 2>&1
echo "IP=" > /var/lib/ipvps.conf

author="ARI STORE"
echo "$author" > /etc/xray/username

NEW_FILE_MAX=65535
SYSCTL_CONF="/etc/sysctl.conf"
grep -q '^fs.file-max' "$SYSCTL_CONF" && sed -i "s/^fs.file-max.*/fs.file-max = $NEW_FILE_MAX/" "$SYSCTL_CONF" || echo "fs.file-max = $NEW_FILE_MAX" >> "$SYSCTL_CONF"
grep -q '^net.netfilter.nf_conntrack_max' "$SYSCTL_CONF" || echo 'net.netfilter.nf_conntrack_max=262144' >> "$SYSCTL_CONF"
grep -q '^net.netfilter.nf_conntrack_tcp_timeout_time_wait' "$SYSCTL_CONF" || echo 'net.netfilter.nf_conntrack_tcp_timeout_time_wait=30' >> "$SYSCTL_CONF"
sysctl -p >/dev/null 2>&1 || true

clear
Pasang
setup_domain
Installasi

# Setup DNS lebih aman
if command -v chattr >/dev/null 2>&1; then
  chattr -i /etc/resolv.conf >/dev/null 2>&1 || true
fi
cat > /etc/resolv.conf <<DNS
nameserver 8.8.8.8
nameserver 1.1.1.1
DNS

cat > /etc/profile.d/v7_repo.sh <<'ENDREPO'
export V7_REPO_DIR="${V7_REPO_DIR:-/opt/v8-installer/current}"
ENDREPO
chmod 644 /etc/profile.d/v7_repo.sh

cat > /root/.profile <<'END'
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
rm -f /root/log-install.txt /etc/afak.conf >/dev/null 2>&1 || true
history -c || true

if [ -f "$(v7_repo_path versi)" ]; then
  cat "$(v7_repo_path versi)" > /opt/.ver
fi

curl -sS ifconfig.me > /etc/myipvps || true
curl -sS ipinfo.io/city?token=75082b4831f909 > /etc/xray/city || echo "-" > /etc/xray/city
curl -sS ipinfo.io/org?token=75082b4831f909 | cut -d ' ' -f 2-10 > /etc/xray/isp || echo "-" > /etc/xray/isp

secs_to_human "$(( $(date +%s) - ${start:-$(date +%s)} ))" | tee -a /root/log-install.txt
sleep 1

iinfo

API_TOKEN_FILE="/etc/api-ari/auth.key"
API_PORT="5888"

echo -e "${green}┌────────────────────────────────────────────┐${NC}"
echo -e "${green}│${bold_white}          ✅ INSTALLASI SELESAI             ${green}│${NC}"
echo -e "${green}└────────────────────────────────────────────┘${NC}"
echo
echo -e "Repo lokal       : ${yellow}${V7_REPO_DIR}${NC}"
echo -e "IP VPS           : ${yellow}$(cat /etc/myipvps 2>/dev/null || echo '-')${NC}"
echo -e "Domain           : ${yellow}$(cat /etc/xray/domain 2>/dev/null || echo '-')${NC}"
if [ -f "$API_TOKEN_FILE" ]; then
  echo -e "API port         : ${yellow}${API_PORT}${NC}"
  echo -e "API token        : ${yellow}$(cat "$API_TOKEN_FILE")${NC}"
fi
echo
echo -e "Menu akan dibuka..."
sleep 2
/usr/local/sbin/menu || true
