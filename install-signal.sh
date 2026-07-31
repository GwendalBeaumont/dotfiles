#!/usr/bin/env bash
set -xeuo pipefail

APPIMAGE_URL="https://updates.signal.org/desktop/signal-desktop.AppImage"
SIGNATURE_URL="https://updates.signal.org/desktop/signal-desktop.AppImage.gpg"
KEY_URL="https://updates.signal.org/static/desktop/appimage.asc"

# Signal's published AppImage signing key fingerprint.
EXPECTED_FINGERPRINT="4B16B7232DFAA439AD791002EF9F501F13EED94C"

BIN_DIR="$HOME/.local/bin"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
APPLICATIONS_DIR="$DATA_HOME/applications"
ICONS_DIR="$DATA_HOME/icons"

APP_PATH="$BIN_DIR/signal-desktop"
DESKTOP_FILE="$APPLICATIONS_DIR/signal-appimage.desktop"
DESKTOP_ID="signal-appimage.desktop"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

for cmd in bash curl gpg install mktemp cp rm chmod awk; do
  need "$cmd"
done

case "$(uname -m)" in
  x86_64|amd64)
    ;;
  *)
    printf 'warning: Signal’s official AppImage is intended for 64-bit x86 Linux; this machine reports %s\n' "$(uname -m)" >&2
    ;;
esac

tmp="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

appimage_tmp="$tmp/signal-desktop.AppImage"
signature_tmp="$tmp/signal-desktop.AppImage.gpg"
key_tmp="$tmp/signal-appimage.asc"

curl -fL --retry 3 --retry-delay 2 -o "$appimage_tmp" "$APPIMAGE_URL"
curl -fL --retry 3 --retry-delay 2 -o "$signature_tmp" "$SIGNATURE_URL"
curl -fL --retry 3 --retry-delay 2 -o "$key_tmp" "$KEY_URL"

export GNUPGHOME="$tmp/gnupg"
install -d -m 700 "$GNUPGHOME"

actual_fingerprint="$(
  gpg --batch --with-colons --show-keys "$key_tmp" \
    | awk -F: '$1 == "fpr" { print $10; exit }'
)"

if [[ "$actual_fingerprint" != "$EXPECTED_FINGERPRINT" ]]; then
  die "unexpected Signal AppImage signing key fingerprint: $actual_fingerprint"
fi

gpg --batch --import "$key_tmp" >/dev/null
gpg --batch --verify "$signature_tmp" "$appimage_tmp"

install -d "$BIN_DIR"
chmod 0755 "$appimage_tmp"

new_app_path="$BIN_DIR/.signal-desktop.new.$$"
install -m 0755 "$appimage_tmp" "$new_app_path"
mv -f "$new_app_path" "$APP_PATH"

install -d "$APPLICATIONS_DIR"

desktop_tmp="$(mktemp "$APPLICATIONS_DIR/.signal-appimage.desktop.XXXXXX")"
cat > "$desktop_tmp" <<EOF
[Desktop Entry]
Name=Signal
Exec=$APP_PATH %U
Terminal=false
Type=Application
Icon=signal-desktop
StartupWMClass=signal
Comment=Private messaging from your desktop
MimeType=x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;
Categories=Network;InstantMessaging;Chat;
EOF

chmod 0644 "$desktop_tmp"
mv -f "$desktop_tmp" "$DESKTOP_FILE"

extract_dir="$tmp/extracted"
install -d "$extract_dir"

(
  cd "$extract_dir"

  "$APP_PATH" --appimage-extract 'usr/share/icons/*' >/dev/null
)

icons_src="$extract_dir/squashfs-root/usr/share/icons"
[[ -d "$icons_src" ]] || die "could not find usr/share/icons inside extracted AppImage"

install -d "$ICONS_DIR"
cp -a "$icons_src"/. "$ICONS_DIR"/

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPLICATIONS_DIR" || true
fi

if command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default "$DESKTOP_ID" x-scheme-handler/sgnl || true
  xdg-mime default "$DESKTOP_ID" x-scheme-handler/signalcaptcha || true
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1 && [[ -d "$ICONS_DIR/hicolor" ]]; then
  gtk-update-icon-cache -q -f -t "$ICONS_DIR/hicolor" || true
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
  kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
fi
