#!/usr/bin/env bash
set -euo pipefail

# install.sh - Instalador automático Yabai + Skhd para macOS
# Yabal-Ramos - Gabriel Ramos

# Cores para output
red()   { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow(){ printf "\033[33m%s\033[0m\n" "$*"; }
blue()  { printf "\033[34m%s\033[0m\n" "$*"; }
info()  { printf "• %s\n" "$*"; }

banner() {
cat <<'EOF'
██╗   ██╗ █████╗ ██████╗  █████╗ ██╗      
╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║      
 ╚████╔╝ ███████║██████╔╝███████║██║      
  ╚██╔╝  ██╔══██║██╔══██╗██╔══██║██║      
   ██║   ██║  ██║██████╔╝██║  ██║███████╗ 
   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝ 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     YABAL-RAMOS - Window Manager Setup
     macOS Yabai + Skhd Installation Tool
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

check_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    red "❌ Este script é exclusivo para macOS!"
    exit 1
  fi
  
  local version=$(sw_vers -productVersion)
  blue "macOS detectado: $version"
}

check_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    yellow "Homebrew não encontrado. Instalando..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  green "✅ Homebrew disponível"
}

install_yabai_skhd() {
  info "Instalando Yabai e Skhd..."
  
  # Adicionar tap se não existir
  brew tap koekeishiya/formulae 2>/dev/null || true
  
  # Instalar yabai
  if ! command -v yabai >/dev/null 2>&1; then
    brew install koekeishiya/formulae/yabai
    green "✅ Yabai instalado"
  else
    yellow "⚠️  Yabai já está instalado"
  fi
  
  # Instalar skhd
  if ! command -v skhd >/dev/null 2>&1; then
    brew install koekeishiya/formulae/skhd
    green "✅ Skhd instalado"
  else
    yellow "⚠️  Skhd já está instalado"
  fi
}

create_configs() {
  info "Criando arquivos de configuração..."
  
  # Configuração básica do skhd
  if [[ ! -f ~/.skhdrc ]]; then
    cp /opt/homebrew/opt/skhd/share/skhd/examples/skhdrc ~/.skhdrc
    green "✅ Arquivo ~/.skhdrc criado"
  else
    yellow "⚠️  ~/.skhdrc já existe"
  fi
  
  # Configuração básica do yabai
  if [[ ! -f ~/.yabairc ]]; then
    cat > ~/.yabairc <<'YABAIRC'
#!/usr/bin/env sh

# Configuração básica do Yabai
yabai -m config mouse_follows_focus          off
yabai -m config focus_follows_mouse          off
yabai -m config window_origin_display        default
yabai -m config window_placement             second_child
yabai -m config window_topmost               off
yabai -m config window_shadow                on
yabai -m config window_opacity               off
yabai -m config window_opacity_duration      0.0
yabai -m config active_window_opacity        1.0
yabai -m config normal_window_opacity        0.90
yabai -m config window_border                off
yabai -m config window_border_width          6
yabai -m config active_window_border_color   0xff775759
yabai -m config normal_window_border_color   0xff555555
yabai -m config insert_feedback_color        0xffd75f5f
yabai -m config split_ratio                  0.50
yabai -m config auto_balance                 off
yabai -m config mouse_modifier               fn
yabai -m config mouse_action1                move
yabai -m config mouse_action2                resize
yabai -m config mouse_drop_action            swap

# Layout geral
yabai -m config layout                       bsp
yabai -m config top_padding                  12
yabai -m config bottom_padding               12
yabai -m config left_padding                 12
yabai -m config right_padding                12
yabai -m config window_gap                   06

echo "Yabai configuration loaded"
YABAIRC
    chmod +x ~/.yabairc
    green "✅ Arquivo ~/.yabairc criado"
  else
    yellow "⚠️  ~/.yabairc já existe"
  fi
}

start_services() {
  info "Iniciando serviços..."
  
  # Iniciar como serviços LaunchAgent
  yabai --start-service
  skhd --start-service
  
  green "✅ Serviços iniciados"
}

grant_permissions() {
  info "Configurando permissões de Acessibilidade..."
  
  cat <<'PERMISSIONS_INFO'

🔐 PERMISSÕES NECESSÁRIAS:

Para funcionamento completo, você precisa conceder permissões de Acessibilidade.

ESCOLHA UM MÉTODO:

1️⃣ AUTOMÁTICO (Recomendado se Terminal tem Full Disk Access):
   ./auto-grant-accessibility.sh

2️⃣ MANUAL (Sempre funciona):
   ./grant-accessibility.sh
   
   E adicione manualmente:
   • /opt/homebrew/bin/yabai
   • /opt/homebrew/bin/skhd
   • Terminal.app

3️⃣ AJUDA VISUAL:
   ./tcc-manual-setup.sh

PERMISSIONS_INFO

  yellow "💡 Execute um dos scripts acima após esta instalação!"
}

test_installation() {
  info "Testando instalação..."
  
  sleep 2
  
  if yabai -m signal --list >/dev/null 2>&1; then
    green "✅ Yabai funcionando!"
  else
    yellow "⚠️  Yabai precisa de permissões de Acessibilidade"
  fi
  
  if pgrep -x skhd >/dev/null; then
    green "✅ Skhd funcionando!"
  else
    yellow "⚠️  Skhd pode precisar de configuração adicional"
  fi
}

show_next_steps() {
  cat <<'NEXT_STEPS'

🎉 INSTALAÇÃO CONCLUÍDA!

📋 PRÓXIMOS PASSOS:

1. Conceder permissões de Acessibilidade:
   ./auto-grant-accessibility.sh OU ./grant-accessibility.sh

2. Testar funcionamento:
   yabai -m query --spaces
   yabai -m query --windows

3. Personalizar configurações:
   nano ~/.yabairc
   nano ~/.skhdrc

4. Reiniciar serviços após mudanças:
   yabai --restart-service
   skhd --restart-service

📚 DOCUMENTAÇÃO:
   • Yabai: https://github.com/koekeishiya/yabai
   • Skhd: https://github.com/koekeishiya/skhd

🐛 PROBLEMAS? Execute:
   ./troubleshoot.sh

NEXT_STEPS
}

main() {
  banner
  echo
  
  check_macos
  check_homebrew
  install_yabai_skhd
  create_configs
  start_services
  grant_permissions
  test_installation
  
  echo
  show_next_steps
}

main "$@"