#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="irulgood"
REPO_NAME="v8"
REPO_BRANCH="${1:-main}"
INSTALL_ROOT="/opt/v8-installer"
WORKDIR="$INSTALL_ROOT/work"
CURRENT="$INSTALL_ROOT/current"
ZIPFILE="$WORKDIR/repo.zip"

apt-get update -y >/dev/null 2>&1
apt-get install -y curl unzip ca-certificates >/dev/null 2>&1
mkdir -p "$WORKDIR"
rm -rf "$WORKDIR"/*

ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_BRANCH}.zip"
echo "[INFO] Download repo: $ARCHIVE_URL"
curl -L --fail --silent --show-error "$ARCHIVE_URL" -o "$ZIPFILE"
unzip -oq "$ZIPFILE" -d "$WORKDIR"
EXTRACTED="$(find "$WORKDIR" -maxdepth 2 -type f -name setup.sh | head -n1 | xargs dirname)"
[ -n "$EXTRACTED" ] || { echo "[ERROR] setup.sh tidak ditemukan di archive"; exit 1; }
rm -rf "$CURRENT"
mkdir -p "$INSTALL_ROOT"
cp -a "$EXTRACTED" "$CURRENT"

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

if [ ! -f "$CURRENT/lib/local_repo.sh" ]; then
  echo "[WARN] lib/local_repo.sh tidak ditemukan di repo, membuat helper fallback..."
  write_local_repo_helper "$CURRENT/lib/local_repo.sh"
fi
chmod +x "$CURRENT/setup.sh"
export V7_REPO_DIR="$CURRENT"
bash "$CURRENT/setup.sh"
