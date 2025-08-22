#!/usr/bin/env bash
set -euo pipefail

# troubleshoot.sh - Diagnóstico e soluções para Yabai/Skhd

red()   { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }
blue()  { printf "\033[34m%s\033[0m\n" "$*"; }
info()  { printf "• %s\n" "$*"; }

banner() {
cat <<'EOF'
🔧 YABAL-RAMOS TROUBLESHOOT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

check_installation() {
  blue "1. VERIFICANDO INSTALAÇÃO..."
  
  if command -v yabai >/dev/null 2>&1; then
    green "✅ Yabai instalado: $(yabai --version)"
  else
    red "❌ Yabai não encontrado"
    yellow "💡 Execute: brew install koekeishiya/formulae/yabai"
  fi
  
  if command -v skhd >/dev/null 2>&1; then
    green "✅ Skhd instalado: $(skhd --version)"
  else
    red "❌ Skhd não encontrado"
    yellow "💡 Execute: brew install koekeishiya/formulae/skhd"
  fi
  echo
}

check_services() {
  blue "2. VERIFICANDO SERVIÇOS..."
  
  if launchctl list | grep -q com.koekeishiya.yabai; then
    green "✅ Serviço Yabai ativo"
  else
    red "❌ Serviço Yabai inativo"
    yellow "💡 Execute: yabai --start-service"
  fi
  
  if launchctl list | grep -q com.koekeishiya.skhd; then
    green "✅ Serviço Skhd ativo"
  else
    red "❌ Serviço Skhd inativo"
    yellow "💡 Execute: skhd --start-service"
  fi
  echo
}

check_permissions() {
  blue "3. VERIFICANDO PERMISSÕES..."
  
  if yabai -m signal --list >/dev/null 2>&1; then
    green "✅ Yabai tem permissões de Acessibilidade"
  else
    red "❌ Yabai SEM permissões de Acessibilidade"
    yellow "💡 Execute: ./grant-accessibility.sh ou ./auto-grant-accessibility.sh"
  fi
  
  if pgrep -x skhd >/dev/null; then
    green "✅ Skhd está rodando"
  else
    red "❌ Skhd não está rodando"
    yellow "💡 Verifique ~/.skhdrc e execute: skhd --restart-service"
  fi
  echo
}

check_configs() {
  blue "4. VERIFICANDO CONFIGURAÇÕES..."
  
  if [[ -f ~/.yabairc ]]; then
    green "✅ ~/.yabairc existe"
    if [[ -x ~/.yabairc ]]; then
      green "✅ ~/.yabairc é executável"
    else
      yellow "⚠️  ~/.yabairc não é executável"
      yellow "💡 Execute: chmod +x ~/.yabairc"
    fi
  else
    red "❌ ~/.yabairc não encontrado"
    yellow "💡 Crie um arquivo de configuração básico"
  fi
  
  if [[ -f ~/.skhdrc ]]; then
    green "✅ ~/.skhdrc existe"
  else
    red "❌ ~/.skhdrc não encontrado"
    yellow "💡 Execute: cp /opt/homebrew/opt/skhd/share/skhd/examples/skhdrc ~/.skhdrc"
  fi
  echo
}

check_system() {
  blue "5. VERIFICANDO SISTEMA..."
  
  local macos_version=$(sw_vers -productVersion)
  info "macOS: $macos_version"
  
  if csrutil status | grep -q "System Integrity Protection status: enabled"; then
    yellow "⚠️  SIP habilitado (pode limitar algumas funcionalidades)"
  else
    info "SIP desabilitado"
  fi
  
  if [[ -r "/Library/Application Support/com.apple.TCC/TCC.db" ]]; then
    green "✅ Terminal tem Full Disk Access"
  else
    red "❌ Terminal SEM Full Disk Access"
    yellow "💡 Configurações → Privacidade → Acesso Total ao Disco → Adicionar Terminal"
  fi
  echo
}

show_common_solutions() {
  blue "6. SOLUÇÕES COMUNS..."
  
  cat <<'SOLUTIONS'
🔧 PROBLEMAS FREQUENTES:

❌ Yabai não responde:
   → sudo yabai --load-sa
   → yabai --restart-service

❌ Skhd não funciona:
   → Verificar ~/.skhdrc (sem erros de sintaxe)
   → skhd --restart-service

❌ Permissões negadas:
   → ./grant-accessibility.sh (método manual)
   → ./auto-grant-accessibility.sh (método automático)

❌ Serviços não iniciam:
   → killall yabai skhd
   → yabai --start-service && skhd --start-service

❌ Configuração não carrega:
   → chmod +x ~/.yabairc
   → Verificar sintaxe do arquivo

❌ Brew não encontra formulae:
   → brew tap koekeishiya/formulae
   → brew update

🔄 RESET COMPLETO:
   → yabai --stop-service && skhd --stop-service
   → rm -f ~/.yabairc ~/.skhdrc
   → ./install.sh

SOLUTIONS
}

show_logs() {
  blue "7. VERIFICANDO LOGS..."
  
  echo "📋 Logs recentes do Yabai:"
  tail -n 5 /tmp/yabai_*.log 2>/dev/null || echo "  Nenhum log encontrado"
  
  echo
  echo "📋 Logs recentes do Skhd:"
  tail -n 5 /tmp/skhd_*.log 2>/dev/null || echo "  Nenhum log encontrado"
  echo
}

interactive_fix() {
  blue "8. CORREÇÃO INTERATIVA..."
  
  echo "Deseja tentar uma correção automática? (y/n)"
  read -r response
  
  if [[ "$response" =~ ^[Yy]$ ]]; then
    info "Reiniciando serviços..."
    yabai --restart-service 2>/dev/null || yabai --start-service
    skhd --restart-service 2>/dev/null || skhd --start-service
    
    sleep 3
    
    info "Testando novamente..."
    if yabai -m signal --list >/dev/null 2>&1; then
      green "✅ Problema resolvido!"
    else
      red "❌ Problema persiste. Consulte as soluções acima."
    fi
  fi
}

main() {
  banner
  echo
  
  check_installation
  check_services
  check_permissions
  check_configs
  check_system
  show_common_solutions
  show_logs
  interactive_fix
}

main "$@"