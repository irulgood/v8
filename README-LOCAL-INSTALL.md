# V7 Fixed - Local Repo Installer

## Pola baru install
- Hanya download repo sekali di awal.
- Repo di-unzip ke `/opt/v8-installer/current`.
- Semua file internal repo dijalankan dari folder lokal.
- Download eksternal tetap ada hanya untuk dependency pihak ketiga, misalnya:
  - certbot / package apt
  - Xray installer resmi
  - source vnstat
  - wondershaper git clone
  - binary/script pihak ketiga lain yang memang bukan bagian repo ini

## Cara install yang disarankan
```bash
apt update -y && apt install -y curl unzip && \
curl -L -sS https://raw.githubusercontent.com/irulgood/v8/main/start -o start && \
bash start main
```

## Alternatif
```bash
apt update -y && apt install -y curl unzip && \
curl -L -sS https://raw.githubusercontent.com/irulgood/v8/main/bootstrap.sh -o bootstrap.sh && \
bash bootstrap.sh main
```

## File yang dipatch
- `setup.sh`
- `bootstrap.sh`
- `start`
- `lib/local_repo.sh`
- `menu/update.sh`
- `install/limit.sh`
- `install/set-br.sh`
- `install/vpn.sh`
- `install/ssh-vpn.sh`
- `install/ins-xray.sh`
- `install/autocpu.sh`
- `slowdns/installsl.sh`
- `sshws/insshws.sh`
- `sshws/ohp.sh`
- `api/install-api.sh`
- `menu/menu` (di dalam `menu.zip` juga sudah diperbarui)
- `menu/update` (di dalam `menu.zip` juga sudah diperbarui)
- `menu/fixhap` (di dalam `menu.zip` juga sudah diperbarui)

## Catatan
- API lokal dipasang dari `api/api-ari.zip` ke `/opt/api-ari`.
- AUTH_KEY API dibuat otomatis dan disimpan di `/etc/api-ari/auth.key`.
- Port API default: `5888`.
