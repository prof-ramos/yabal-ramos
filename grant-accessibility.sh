#!/usr/bin/env bash
set -euo pipefail

# grant-accessibility.sh
# Dá (ou facilita) permissão de Acessibilidade para Yabai, Skhd e Terminal no macOS.

# --- Config ---
YABAI_BIN="$(command -v yabai || true)"
SKHD_BIN="$(command -v skhd || true)"
TERMINAL_APP="/System/Applications/Utilities/Terminal.app"
TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"
SERVICE="kTCCServiceAccessibility"

red()   { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }
info()  { printf "• %s\n" "$*"; }

need_root() {
  if [[ $EUID -ne 0 ]]; then
    red "Este script precisa de sudo para parte das operações."
    exec sudo --preserve-env=YABAI_BIN,SKHD_BIN,TERMINAL_APP,TCC_DB,SERVICE bash "$0" "$@"
  fi
}

open_settings_accessibility() {
  # Abre a tela exata de Acessibilidade (Ventura/Sonoma/Sequoia)
  info "Abrindo Configurações do Sistema → Privacidade e Segurança → Acessibilidade…"
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility" \
    || open "x-apple.systempreferences:com.apple.PreferenceSecurity?Privacy_Accessibility" \
    || open "/System/Library/PreferencePanes/Security.prefPane"
  cat <<'TXT'

Passos manuais (recomendado pela Apple):
  1) Clique no cadeado e autentique.
  2) Clique no botão "+" e adicione, nesta ordem (se aparecerem):
       - /opt/homebrew/bin/yabai
       - /opt/homebrew/bin/skhd
       - Terminal (em /System/Applications/Utilities/Terminal.app)
  3) Marque as chaves ao lado de cada um.
  4) Feche as Configurações.

Dica: se não vir o Yabai/Skhd na lista, tente iniciar o serviço primeiro:
    brew services start yabai
    brew services start skhd
e depois volte a esta tela.

TXT
}

check_paths() {
  local missing=0
  if [[ -z "${YABAI_BIN}" || ! -x "${YABAI_BIN}" ]]; then
    yellow "Yabai não encontrado no PATH. Instale com: brew install koekeishiya/formulae/yabai"
    missing=1
  else
    info "Yabai: ${YABAI_BIN}"
  fi
  if [[ -z "${SKHD_BIN}" || ! -x "${SKHD_BIN}" ]]; then
    yellow "Skhd não encontrado no PATH. (opcional) Instale com: brew install koekeishiya/formulae/skhd"
  else
    info "Skhd:  ${SKHD_BIN}"
  fi
  if [[ ! -d "${TERMINAL_APP}" ]]; then
    red "Terminal.app não encontrado em ${TERMINAL_APP} (caminho padrão mudou?)."
    missing=1
  else
    info "Terminal: ${TERMINAL_APP}"
  fi
  return ${missing}
}

have_full_disk_access_hint() {
  cat <<'HINT'
⚠️  Para automação via banco TCC:
    - Abra Configurações do Sistema → Privacidade e Segurança → Acesso Total ao Disco
    - Adicione o Terminal (ou iTerm2) que você está usando e mantenha-o aberto.
    - Execute este script com sudo.
HINT
}

sql_insert_client_path() {
  # Insere entrada por caminho de binário (client_type=1).
  # Esquema simplificado (pode variar por versão):
  # access(service, client, client_type, allowed, prompt_count, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, flags, last_modified)
  local path="$1"
  [[ -z "${path}" ]] && return 0
  if [[ ! -x "${path}" && ! -e "${path}" ]]; then
    yellow "Ignorando (não existe): ${path}"
    return 0
  fi
  sqlite3 "${TCC_DB}" <<SQL
INSERT OR REPLACE INTO access
  (service, client, client_type, allowed, prompt_count, csreq, policy_id,
   indirect_object_identifier_type, indirect_object_identifier, flags, last_modified)
VALUES
  ('${SERVICE}', '${path}', 1, 1, 0, NULL, 0,
   0, NULL, 0, strftime('%s','now'));
SQL
}

sql_insert_bundle_id() {
  # Para apps bundle (client_type=0) usamos o bundle id.
  local app_path="$1"
  [[ ! -d "${app_path}" ]] && { yellow "Ignorando (não é app): ${app_path}"; return 0; }
  local bid
  bid=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "${app_path}/Contents/Info.plist" 2>/dev/null || true)
  if [[ -z "${bid}" ]]; then
    yellow "Bundle ID não encontrado para ${app_path}"
    return 0
  fi
  sqlite3 "${TCC_DB}" <<SQL
INSERT OR REPLACE INTO access
  (service, client, client_type, allowed, prompt_count, csreq, policy_id,
   indirect_object_identifier_type, indirect_object_identifier, flags, last_modified)
VALUES
  ('${SERVICE}', '${bid}', 0, 1, 0, NULL, 0,
   0, NULL, 0, strftime('%s','now'));
SQL
}

validate_sqlite() {
  sqlite3 "${TCC_DB}" "SELECT service,client,client_type,allowed FROM access WHERE service='${SERVICE}' AND (client='${YABAI_BIN}' OR client='${SKHD_BIN}' OR client='com.apple.Terminal');" \
    | sed 's/^/  -> /'
}

main() {
  local mode="${1:-safe}"

  check_paths || true

  if [[ "${mode}" != "--advanced" ]]; then
    open_settings_accessibility
    exit 0
  fi

  # --- Modo avançado ---
  need_root "$@"

  if [[ ! -f "${TCC_DB}" ]]; then
    red "TCC.db não encontrado em: ${TCC_DB}"
    open_settings_accessibility
    exit 1
  fi

  have_full_disk_access_hint

  info "Aplicando entradas no TCC (pode não funcionar em versões mais recentes do macOS)…"
  # Terminal por Bundle ID
  sql_insert_bundle_id "${TERMINAL_APP}"
  # Yabai/Skhd por caminho
  [[ -n "${YABAI_BIN}" ]] && sql_insert_client_path "${YABAI_BIN}"
  [[ -n "${SKHD_BIN}"  ]] && sql_insert_client_path "${SKHD_BIN}"

  green "Validação das entradas gravadas:"
  validate_sqlite || true

  yellow "Se algum item não apareceu ou o macOS ignorar as entradas, use o modo seguro:"
  open_settings_accessibility
}

main "$@"