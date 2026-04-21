#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export V7_REPO_DIR="${V7_REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
. "$V7_REPO_DIR/lib/local_repo.sh"

APP_BASE="/opt/api-ari"
APP_DIR="$APP_BASE/api-ari"
ENV_DIR="/etc/api-ari"
TOKEN_FILE="$ENV_DIR/auth.key"
PORT="5888"

mkdir -p "$APP_BASE" "$ENV_DIR"
rm -rf "$APP_DIR"
v7_unzip_to api/api-ari.zip "$APP_BASE"

cd "$APP_DIR"
if [ ! -f package.json ]; then
  npm init -y >/dev/null 2>&1
fi
npm install express >/dev/null 2>&1

if [ ! -f "$TOKEN_FILE" ]; then
  printf 'IRULTUN%s\n' "$(tr -dc 'A-Z0-9' </dev/urandom | head -c 14)" > "$TOKEN_FILE"
fi
AUTH_KEY="$(cat "$TOKEN_FILE")"

cat > "$ENV_DIR/api.env" <<ENV
AUTH_KEY=$AUTH_KEY
PORT=$PORT
ENV

cat > /etc/systemd/system/api-ari.service <<SERVICE
[Unit]
Description=API ARI Local Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$APP_DIR
EnvironmentFile=$ENV_DIR/api.env
Environment=PORT=$PORT
ExecStart=/usr/bin/env node $APP_DIR/api.js
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now api-ari.service >/dev/null 2>&1

echo "[INFO] API lokal aktif di port $PORT"
echo "[INFO] AUTH_KEY: $AUTH_KEY"
