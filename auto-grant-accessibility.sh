#!/usr/bin/env bash
set -euo pipefail

# auto-grant-accessibility.sh
# Script automatizado para macOS Sequoia+ com nova estrutura TCC

red()   { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }
info()  { printf "• %s\n" "$*"; }

# Configurações
YABAI_BIN="/opt/homebrew/bin/yabai"
SKHD_BIN="/opt/homebrew/bin/skhd"
TERMINAL_BUNDLE="com.apple.Terminal"
TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"
SERVICE="kTCCServiceAccessibility"

check_root() {
  if [[ $EUID -ne 0 ]]; then
    red "Este script precisa de sudo para modificar o banco TCC."
    exit 1
  fi
}

grant_accessibility_permission() {
  local client="$1"
  local client_type="$2"  # 0 = bundle ID, 1 = path
  
  info "Concedendo permissão para: $client"
  
  # Remove entrada existente se houver
  sqlite3 "$TCC_DB" "DELETE FROM access WHERE service='$SERVICE' AND client='$client';" 2>/dev/null || true
  
  # Adiciona nova entrada com estrutura atualizada do macOS Sequoia
  sqlite3 "$TCC_DB" <<SQL
INSERT OR REPLACE INTO access (
  service, client, client_type, auth_value, auth_reason, auth_version,
  csreq, policy_id, indirect_object_identifier_type, 
  indirect_object_identifier, flags, last_modified
) VALUES (
  '$SERVICE', '$client', $client_type, 2, 3, 1,
  NULL, 0, 0, 
  'UNUSED', 0, CAST(strftime('%s','now') AS INTEGER)
);
SQL
}

restart_services() {
  info "Reiniciando serviços..."
  
  # Obter o usuário real (não root)
  REAL_USER=$(who | awk 'NR==1{print $1}')
  
  # Parar e reiniciar como usuário normal
  sudo -u "$REAL_USER" launchctl unload ~/Library/LaunchAgents/com.koekeishiya.yabai.plist 2>/dev/null || true
  sudo -u "$REAL_USER" launchctl unload ~/Library/LaunchAgents/com.koekeishiya.skhd.plist 2>/dev/null || true
  
  sleep 2
  
  sudo -u "$REAL_USER" launchctl load ~/Library/LaunchAgents/com.koekeishiya.yabai.plist 2>/dev/null || true
  sudo -u "$REAL_USER" launchctl load ~/Library/LaunchAgents/com.koekeishiya.skhd.plist 2>/dev/null || true
  
  sleep 2
}

verify_permissions() {
  info "Verificando permissões concedidas..."
  
  sqlite3 "$TCC_DB" "SELECT service || ' | ' || client || ' | Auth: ' || auth_value FROM access WHERE service='$SERVICE' AND (client='$YABAI_BIN' OR client='$SKHD_BIN' OR client='$TERMINAL_BUNDLE');" | while read -r line; do
    echo "  ✓ $line"
  done
}

test_yabai() {
  info "Testando se Yabai funciona..."
  
  REAL_USER=$(who | awk 'NR==1{print $1}')
  
  if sudo -u "$REAL_USER" yabai -m signal --list >/dev/null 2>&1; then
    green "✅ Yabai funcionando corretamente!"
    return 0
  else
    yellow "⚠️  Yabai ainda não funciona. Pode precisar reiniciar ou aguardar."
    return 1
  fi
}

main() {
  echo "🔧 Automatizando permissões TCC para macOS Sequoia+..."
  echo
  
  check_root
  
  info "Concedendo permissões via TCC database..."
  
  # Conceder permissões
  grant_accessibility_permission "$YABAI_BIN" 1      # Path
  grant_accessibility_permission "$SKHD_BIN" 1       # Path  
  grant_accessibility_permission "$TERMINAL_BUNDLE" 0 # Bundle ID
  
  verify_permissions
  restart_services
  
  echo
  green "✅ Permissões concedidas via TCC!"
  
  sleep 3
  test_yabai
  
  echo
  info "Se ainda não funcionar, execute: sudo killall Dock"
}

main "$@"