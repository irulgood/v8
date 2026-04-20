#!/bin/bash

# Nonaktifkan IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# SET MANUAL (tanpa GitHub)
username="localuser"
valid="4000-12-31"
echo "$username" > /usr/bin/user
echo "$valid" > /usr/bin/e

REPO="http://raw.githubusercontent.com/irulgood/v7/main/"

# ==========================================
# DEFINISI WARNA
# ==========================================
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
NC='\033[0m'
green="\e[38;5;82m"
red="\e[38;5;196m"
neutral="\e[0m"
orange="\e[38;5;130m"
blue="\e[38;5;39m"
yellow="\e[38;5;226m"
purple="\e[38;5;141m"
bold_white="\e[1;37m"
pink="\e[38;5;205m"
reset="\e[0m"
gray="\e[38;5;245m"
# Fungsi warna
purple() { echo -e "\\033[35;1m${*}\${NC}"; }
tyblue() { echo -e "\\033[36;1m${*}\${NC}"; }
yellow() { echo -e "\\033[33;1m${*}\${NC}"; }
green() { echo -e "\\033[32;1m${*}\${NC}"; }
red() { echo -e "\\033[31;1m${*}\${NC}"; }

# ==========================================
# FUNGSI UTILITAS
# ==========================================
function secs_to_human() {
    echo "Waktu instalasi : $(( ${1} / 3600 )) jam $(( (${1} / 60) % 60 )) menit $(( ${1} % 60 )) detik"
}

function fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch $HOME/fim
    ) >/dev/null 2>&1 &
    
    tput civis
    echo -ne "  ${bold_white}🔄 Menginstal File ${bold_white}- ${green}["
    
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  ${bold_white}🔄 Menginstal File ${bold_white}- ${green}["
    done
    
    echo -e "${green}]${bold_white} -${green} ✅ Sukses !${bold_white}"
    tput cnorm
}

# ==========================================
# FUNGSI UTAMA
# ==========================================
function CEKIP() {
    MYIP=$(curl -sS ipv4.icanhazip.com)
    if ! curl -sS https://raw.githubusercontent.com/arivpnstores/izin/main/ip | grep -qF "$MYIP"; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        NC='\e[0m'
        echo -e " ${RED}IP VPS Anda tidak terdaftar pada izin${NC}"
        echo -e " ${GREEN}Whatsapp = wa.me/6281327393959 ${NC}"
        echo -e " ${GREEN}Telegram = @ARI_VPN_STORE ${NC}"
        sleep 3
        exit 1
    fi
    echo ""
    rm -f /usr/bin/user
    username=$(curl -sS https://raw.githubusercontent.com/arivpnstores/izin/main/ip | grep $MYIP | awk '{print $2}')
    echo "$username" >/usr/bin/user
    rm -f /usr/bin/e
    today=`date -d "0 days" +"%Y-%m-%d"`
    valid=$(curl -sS https://raw.githubusercontent.com/arivpnstores/izin/main/ip | grep $MYIP | awk '{print $3}')
    echo "$valid" >/usr/bin/e
    username=$(cat /usr/bin/user)
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
    domain
    Pasang
}

function domain() {
    fun_bar() {
        CMD[0]="$1"
        CMD[1]="$2"
        (
            [[ -e $HOME/fim ]] && rm $HOME/fim
            ${CMD[0]} -y >/dev/null 2>&1
            ${CMD[1]} -y >/dev/null 2>&1
            touch $HOME/fim
        ) >/dev/null 2>&1 &
        
        tput civis
        echo -ne "  ${yellow}🔄 Update Domain.. ${bold_white}- ${yellow}["
        while true; do
            for ((i = 0; i < 18; i++)); do
                echo -ne "\033[0;32m#"
                sleep 0.1s
            done
            [[ -e $HOME/fim ]] && rm $HOME/fim && break
            echo -e "\033[0;33m]"
            sleep 1s
            tput cuu1
            tput dl1
            echo -ne "  ${yellow}🔄 Update Domain... ${bold_white}- ${yellow}["
            done
            echo -e "${yellow}]${bold_white} -${green} ✅ Sukses !${bold_white}"
        tput cnorm
    }

    res1() {
        wget ${REPO}install/pointing.sh && chmod +x pointing.sh && ./pointing.sh
        clear
    }

    clear
    cd
    echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${bold_white}              🎯 SETUP DOMAIN VPS              ${NC}"
echo -e "${green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${yellow}------------------------------------------------${NC}"
echo -e "${green} 1. ${bold_white}Gunakan Domain Sendiri${NC}"
echo -e "${green} 2. ${bold_white}Gunakan Domain Random${NC}"
echo -e "${yellow}------------------------------------------------${NC}"
until [[ $domain =~ ^[12]+$ ]]; do
read -p "   Pilih opsi 1 atau 2 : " domain
done
if [[ $domain == "1" ]]; then
echo ""
until [[ $dnss =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "🌐 Masukkan domain Anda: " -e dnss
done
rm -rf /etc/v2ray
rm -rf /etc/nsdomain
rm -rf /etc/per
mkdir -p /etc/xray
mkdir -p /etc/v2ray
mkdir -p /etc/nsdomain
touch /etc/xray/domain
touch /etc/v2ray/domain
touch /etc/xray/slwdomain
touch /etc/v2ray/scdomain
echo "$dnss" > /root/domain
echo "$dnss" > /root/scdomain
echo "$dnss" > /etc/xray/scdomain
echo "$dnss" > /etc/v2ray/scdomain
echo "$dnss" > /etc/xray/domain
echo "$dnss" > /etc/v2ray/domain
echo "IP=$dnss" > /var/lib/ipvps.conf
echo ""
clear
fi
if [[ $domain == "2" ]]; then
clear
echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│  ${bold_white}Contoh: ${gray}free${NC}                            ${green}│${NC}"
echo -e "${green}│  ${bold_white}Akan menjadi: ${gray}free.alhamdulliah.web.id${NC}              ${green}│${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
echo ""
until [[ $dn1 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "🌐 Masukkan subdomain (tanpa spasi): " -e dn1
done
rm -rf /etc/v2ray
rm -rf /etc/nsdomain
rm -rf /etc/per
mkdir -p /etc/xray
mkdir -p /etc/v2ray
mkdir -p /etc/nsdomain
touch /etc/xray/domain
touch /etc/v2ray/domain
touch /etc/xray/slwdomain
touch /etc/v2ray/scdomain
echo "$dn1" > /root/domain
echo "$dn1" > /root/scdomain
echo "$dn1" > /etc/xray/scdomain
echo "$dn1" > /etc/v2ray/scdomain
echo "$dn1" > /etc/xray/domain
echo "$dn1" > /etc/v2ray/domain
echo "IP=$dn1" > /var/lib/ipvps.conf
echo ""
clear
cd
sleep 1
fun_bar 'res1'
clear
rm /root/subdomainx
fi
}

function Pasang() {
    cd
    wget ${REPO}tools.sh &> /dev/null
    chmod +x tools.sh 
    bash tools.sh
    clear
    
    start=$(date +%s)
    ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    apt install git curl -y >/dev/null 2>&1
    apt install python -y >/dev/null 2>&1
}

function Installasi() {
    # Fungsi resource
    res2() { wget ${REPO}install/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh; clear; }
    res3() { wget ${REPO}install/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh; clear; }
    res4() { wget ${REPO}sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh; clear; }
    res5() { wget ${REPO}install/set-br.sh && chmod +x set-br.sh && ./set-br.sh; clear; }
    res6() { wget ${REPO}sshws/ohp.sh && chmod +x ohp.sh && ./ohp.sh; clear; }
    res7() { wget ${REPO}menu/update.sh && chmod +x update.sh && ./update.sh; clear; }
    res8() { wget ${REPO}slowdns/installsl.sh && chmod +x installsl.sh && bash installsl.sh; clear; }
    res9() { wget ${REPO}install/udp-custom.sh && chmod +x udp-custom.sh && bash udp-custom.sh; clear; }
   res10() { wget ${REPO}install/dropbear2019 && chmod +x /etc/dropbear2019 && bash /etc/dropbear2019; clear; }
   res11() { wget -q https://raw.githubusercontent.com/arivpnstores/api-ari/main/api.sh && chmod +x api.sh && ./api.sh && rm -rf api.sh; clear; }


    OS_ID=$(grep -w ID /etc/os-release | head -n1 | cut -d= -f2 | tr -d '"')
    OS_NAME=$(grep -w PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')

    if [[ "$OS_ID" == "ubuntu" ]]; then
        echo -e "${green}Setup nginx Untuk OS $OS_NAME${NC}"
        setup_install

    elif [[ "$OS_ID" == "debian" || "$OS_ID" == "kali" ]]; then
        echo -e "${green}Setup nginx Untuk OS $OS_NAME${NC}"
        setup_install

    else
        echo -e "OS Anda Tidak Didukung (${yell}$OS_NAME${NC})"
    fi
}

function setup_install() {
    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│       MEMASANG SSH & OPENVPN             │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res2

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│           MEMASANG XRAY                  │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res3

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│        MEMASANG WEBSOCKET SSH            │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res4

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│        MEMASANG MENU BACKUP              │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res5

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│           MEMASANG OHP                   │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res6

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│           MENGUNDUH MENU EKSTRA          │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res7

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│           MENGUNDUH SYSTEM               │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res8

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│           MENGUNDUH UDP CUSTOM           │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res9

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│           MENGUNDUH DROPBEAR-2019        │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res10

    echo -e "${green}┌──────────────────────────────────────────┐${NC}"
    echo -e "${green}│           MENGUNDUH ARI-API              │${NC}"
    echo -e "${green}└──────────────────────────────────────────┘${NC}"
    res11
}

function iinfo() {
    domain=$(cat /etc/xray/domain)
    TIMES="10"
    CHATID="ID_TELE"
    KEY="TOKEN_TELE"
    URL="https://api.telegram.org/bot$KEY/sendMessage"
    ISP=$(cat /etc/xray/isp)
    CITY=$(cat /etc/xray/city)
    domain=$(cat /etc/xray/domain) 
    TIME=$(date +'%Y-%m-%d %H:%M:%S')
    RAMMS=$(free -m | awk 'NR==2 {print $2}')
    MODEL2=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
    MYIP=$(curl -sS ipv4.icanhazip.com)
    IZIN=$(curl -sS https://raw.githubusercontent.com/arivpnstores/izin/main/ip | grep $MYIP | awk '{print $3}' )
    d1=$(date -d "$IZIN" +%s)
    d2=$(date -d "$today" +%s)
    EXP=$(( (d1 - d2) / 86400 ))

    TEXT="
<code>━━━━━━━━━━━━━━━━━━━━</code>
<code>⚠️ AUTOSCRIPT PREMIUM ⚠️</code>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<code>NAMA : </code><code>${author}</code>
<code>WAKTU : </code><code>${TIME} WIB</code>
<code>DOMAIN : </code><code>${domain}</code>
<code>IP : </code><code>${MYIP}</code>
<code>ISP : </code><code>${ISP} $CITY</code>
<code>OS LINUX : </code><code>${MODEL2}</code>
<code>RAM : </code><code>${RAMMS} MB</code>
<code>EXP SCRIPT : </code><code>$EXP Hari</code>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<i> Notifikasi Installer Script...</i>
"'&reply_markup={"inline_keyboard":[[{"text":"🔥ᴏʀᴅᴇʀ","url":"https://t.me/ARI_VPN_STORE"},{"text":"🔥GRUP","url":"https://t.me/RAJA_VPN_STORE"}]]}'
    
    curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
    clear
}

# ==========================================
# SETUP AWAL
# ==========================================
cd
if [ "${EUID}" -ne 0 ]; then
    echo "Anda perlu menjalankan script ini sebagai root"
    exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ tidak didukung"
    exit 1
fi

localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')

if [[ "$hst" != "$dart" ]]; then
    echo "$localip $(hostname)" >> /etc/hosts
fi

mkdir -p /etc/xray
mkdir -p /var/lib/ >/dev/null 2>&1
echo "IP=" >> /var/lib/ipvps.conf

clear
name="ARI STORE"
echo "ARI STORE" > /etc/xray/username
echo ""
clear
author=$name
echo ""
echo ""

# ==========================================
# OPTIMISASI SYSTEM
# ==========================================
NEW_FILE_MAX=65535
NF_CONNTRACK_MAX="net.netfilter.nf_conntrack_max=262144"
NF_CONNTRACK_TIMEOUT="net.netfilter.nf_conntrack_tcp_timeout_time_wait=30"
SYSCTL_CONF="/etc/sysctl.conf"

CURRENT_FILE_MAX=$(grep "^fs.file-max" "$SYSCTL_CONF" | awk '{print $3}' 2>/dev/null)

if [ "$CURRENT_FILE_MAX" != "$NEW_FILE_MAX" ]; then
    if grep -q "^fs.file-max" "$SYSCTL_CONF"; then
        sed -i "s/^fs.file-max.*/fs.file-max = $NEW_FILE_MAX/" "$SYSCTL_CONF" >/dev/null 2>&1
    else
        echo "fs.file-max = $NEW_FILE_MAX" >> "$SYSCTL_CONF" 2>/dev/null
    fi
fi

if ! grep -q "^net.netfilter.nf_conntrack_max" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_MAX" >> "$SYSCTL_CONF" 2>/dev/null
fi

if ! grep -q "^net.netfilter.nf_conntrack_tcp_timeout_time_wait" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_TIMEOUT" >> "$SYSCTL_CONF" 2>/dev/null
fi

sysctl -p >/dev/null 2>&1

# ==========================================
# EKSEKUSI UTAMA
# ==========================================
#CEKIP
Installasi

# ==========================================
# SETUP DNS
# ==========================================
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo rm -rf /etc/resolv.config
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
sudo systemctl start systemd-resolved
sudo systemctl enable systemd-resolved

# ==========================================
# SETUP FINAL
# ==========================================
cat> /root/.profile << END
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

if [ -f "/root/log-install.txt" ]; then
    rm /root/log-install.txt > /dev/null 2>&1
fi

if [ -f "/etc/afak.conf" ]; then
    rm /etc/afak.conf > /dev/null 2>&1
fi

history -c
serverV=$( curl -sS ${REPO}versi  )
echo $serverV > /opt/.ver

cd
curl -sS ifconfig.me > /etc/myipvps
curl -s ipinfo.io/city?token=75082b4831f909 >> /etc/xray/city
curl -s ipinfo.io/org?token=75082b4831f909  | cut -d " " -f 2-10 >> /etc/xray/isp

# Membersihkan file
rm /root/tools.sh >/dev/null 2>&1
rm /root/setup.sh >/dev/null 2>&1
rm /root/pointing.sh >/dev/null 2>&1
rm /root/ssh-vpn.sh >/dev/null 2>&1
rm /root/ins-xray.sh >/dev/null 2>&1
rm /root/insshws.sh >/dev/null 2>&1
rm /root/set-br.sh >/dev/null 2>&1
rm /root/ohp.sh >/dev/null 2>&1
rm /root/update.sh >/dev/null 2>&1
rm /root/installsl.sh >/dev/null 2>&1
rm /root/udp-custom.sh >/dev/null 2>&1

secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt
sleep 3

echo ""
cd
iinfo

echo -e "${green}┌────────────────────────────────────────────┐${NC}"
echo -e "${green}│${bold_white}          ✅ INSTALLASI SELESAI             ${green}│${NC}"
echo -e "${green}└────────────────────────────────────────────┘${NC}"
echo ""
echo -e "Menu akan dibuka..."
sleep 2
/usr/local/sbin/menu