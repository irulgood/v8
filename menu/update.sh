#!/bin/bash
# ==================================================
# Script Setup & Update Menu VPS
# ==================================================

# -----------------------------
# Fungsi Animasi Loading
# -----------------------------
loading() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    tput civis
    while [ -d /proc/$pid ]; do
        local temp=${spinstr#?}
        printf " [%c] $message\r" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    tput cnorm
}

# -----------------------------
# Install p7zip jika belum ada
# -----------------------------
if ! command -v 7z &> /dev/null; then
    echo -e " [INFO] Installing p7zip-full..."
    apt install p7zip-full -y &> /dev/null &
    loading $! "Loading Install p7zip-full"
fi

# -----------------------------
# Telegram Bot Config
# -----------------------------
CHATID="ID_TELE"
KEY="TOKEN_TELE"
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"

# -----------------------------
# Variabel Server & User
# -----------------------------
domain=$(cat /etc/xray/domain)
MYIP=$(curl -sS ipv4.icanhazip.com)
echo ""
# SET MANUAL (tanpa GitHub)
username="localuser"
valid="4000-12-31"
echo "$username" > /usr/bin/user
echo "$valid" > /usr/bin/e
today=`date -d "0 days" +"%Y-%m-%d"`
#oid=$(cat /usr/bin/ver)
exp=$(cat /usr/bin/e)
COLOR1='\033[1;36m'
NC='\e[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
clear
d1=$(date -d "$valid" +%s)
d2=$(date -d "$today" +%s)
certifacate=$(((d1 - d2) / 86400))
DATE=$(date +'%Y-%m-%d')
datediff() {
d1=$(date -d "$1" +%s)
d2=$(date -d "$2" +%s)
echo -e "${COLOR1}Expiry In   : $(( (d1 - d2) / 86400 )) Days${NC}"
}
mai=$(datediff "$exp" "$DATE")
Info="${GREEN}Active${NC}"
Error="${RED}Expired${NC}"
if [[ "$certifacate" -le "0" ]]; then
sts="${Error}"
echo -e " ${RED}Masa Aktif Script Kamu Sudah Habis${NC}"
echo -e " ${RED}Silahkan Contact Admin Untuk Perpanjang ${NC}"
echo -e " ${GREEN}Whatsapp = wa.me/6281327393959 ${NC}"
echo -e " ${GREEN}Telegram = @ARI_VPN_STORE ${NC}"
sleep 3
exit 1
else
sts="${Info}"
fi

# Mendapatkan tanggal dari server
echo -e " [INFO] Fetching server date..."
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# Repository
REPO="http://raw.githubusercontent.com/irulgood/v7/main/"

# -----------------------------
# Download & Setup Menu
# -----------------------------
echo -e " [INFO] Downloading menu.zip..."
{
    > /etc/cron.d/cpu_otm

    cat > /etc/cron.d/cpu_ari <<END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/bin/autocpu
END

    wget -O /usr/bin/autocpu "${REPO}install/autocpu.sh" && chmod +x /usr/bin/autocpu
    wget -q ${REPO}menu/menu.zip
    mv menu/expsc /usr/local/sbin/expsc
    wget -q -O /usr/bin/enc "${REPO}install/encrypt"
    chmod +x /usr/bin/enc

    # Extract dan encrypt menu
    unzip menu.zip &> /dev/null
    chmod +x menu/*
    enc menu/* &> /dev/null
    mv menu/* /usr/local/sbin

    # Cleanup
    rm -rf menu menu.zip
    rm -rf /usr/local/sbin/*~ /usr/local/sbin/gz* /usr/local/sbin/*.bak
    cd /usr/local/sbin
    sed -i 's/\r//' quota
    cd
} &> /dev/null &
loading $! "Loading Extract and Setup menu"

# -----------------------------
# Ambil versi server
# -----------------------------
echo -e " [INFO] Fetching server version..."
serverV=$(curl -sS ${REPO}versi)
echo $serverV > /opt/.ver

# Cleanup
rm /root/*.sh*

# -----------------------------
# Kirim Notifikasi Telegram
# -----------------------------
TEXT="◇━━━━━━━━━━━━━━◇
<b>   ⚠️NOTIF UPDATE SCRIPT⚠️</b>
<b>     Update Script Sukses</b>
◇━━━━━━━━━━━━━━◇
<b>IP VPS  :</b> ${MYIP} 
<b>DOMAIN  :</b> ${domain}
<b>Version :</b> ${serverV}
<b>USER    :</b> ${username}
<b>MASA    :</b> $certifacate DAY
◇━━━━━━━━━━━━━━◇
BY BOT : @ARI_VPN_STORE
"

curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null

echo -e " [INFO] File download and setup completed successfully. Version: $serverV!"
exit 0
