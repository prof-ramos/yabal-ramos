# 📖 MANUAL DE USO - YABAL-RAMOS

## 🎯 Visão Geral

**Yabal-Ramos** é um conjunto de scripts para instalação e configuração automatizada do **Yabai** (window manager) e **Skhd** (hotkey daemon) no macOS.

### ✨ Características

- 🚀 **Instalação automatizada** completa
- 🔐 **Configuração de permissões** via TCC
- 🛠️ **Troubleshooting** integrado
- 📋 **Configurações prontas** para uso
- 🎨 **Interface visual** amigável

---

## 🚀 Instalação Rápida

### 1. Instalação Completa
```bash
chmod +x install.sh
./install.sh
```

### 2. Conceder Permissões
Escolha um método:

**Opção A - Automático** (requer Full Disk Access):
```bash
sudo ./auto-grant-accessibility.sh
```

**Opção B - Manual** (sempre funciona):
```bash
./grant-accessibility.sh
```

### 3. Verificar Funcionamento
```bash
yabai -m query --spaces
yabai -m query --windows
```

---

## 📋 Scripts Disponíveis

### 🔧 `install.sh`
**Instalador principal** que configura tudo automaticamente:
- Verifica e instala Homebrew
- Instala Yabai e Skhd
- Cria configurações básicas
- Inicia serviços LaunchAgent

### 🔐 `grant-accessibility.sh` 
**Configuração manual de permissões**:
- Abre Configurações do Sistema
- Guia passo-a-passo visual
- Método oficial da Apple

### ⚡ `auto-grant-accessibility.sh`
**Configuração automática via TCC**:
- Modifica banco de dados TCC diretamente
- Funciona em macOS Sequoia+
- Requer `sudo` e Full Disk Access

### 🩺 `troubleshoot.sh`
**Diagnóstico e solução de problemas**:
- Verifica instalação completa
- Identifica problemas comuns
- Sugestões de correção automática

---

## ⚙️ Configuração

### 📁 Arquivos de Configuração

- **`~/.yabairc`** - Configuração do window manager
- **`~/.skhdrc`** - Atalhos de teclado
- **`~/Library/LaunchAgents/`** - Serviços automáticos

### 🎛️ Configuração Básica do Yabai

O arquivo `~/.yabairc` criado pelo instalador inclui:
```bash
# Layout em árvore binária
yabai -m config layout bsp

# Gaps e padding
yabai -m config window_gap 6
yabai -m config top_padding 12
yabai -m config bottom_padding 12
yabai -m config left_padding 12
yabai -m config right_padding 12

# Mouse interaction
yabai -m config mouse_modifier fn
yabai -m config mouse_action1 move
yabai -m config mouse_action2 resize
```

### ⌨️ Atalhos Padrão do Skhd

O arquivo `~/.skhdrc` usa configurações do exemplo oficial:
- `cmd + alt + r` - Reiniciar Yabai
- `cmd + alt + space` - Alternar floating
- `cmd + alt + h/j/k/l` - Navegar entre janelas
- `cmd + shift + h/j/k/l` - Mover janelas

---

## 🔧 Comandos Úteis

### 🔄 Gerenciamento de Serviços
```bash
# Iniciar serviços
yabai --start-service
skhd --start-service

# Reiniciar serviços
yabai --restart-service
skhd --restart-service

# Parar serviços
yabai --stop-service
skhd --stop-service
```

### 📊 Consultas do Yabai
```bash
# Listar espaços (desktops)
yabai -m query --spaces

# Listar janelas
yabai -m query --windows

# Informações do display
yabai -m query --displays

# Status das regras
yabai -m query --rules
```

### 🎮 Controles Básicos
```bash
# Alternar layout
yabai -m space --layout bsp|stack|float

# Focar janela
yabai -m window --focus west|south|north|east

# Mover janela
yabai -m window --swap west|south|north|east

# Redimensionar
yabai -m window --resize left:-50:0
yabai -m window --resize right:50:0
```

---

## 🚨 Troubleshooting

### ❌ Problemas Comuns

**Yabai não responde:**
```bash
./troubleshoot.sh
# ou
sudo yabai --load-sa
yabai --restart-service
```

**Permissões negadas:**
```bash
./grant-accessibility.sh
# Adicionar manualmente:
# /opt/homebrew/bin/yabai
# /opt/homebrew/bin/skhd
# Terminal.app
```

**Skhd não funciona:**
```bash
# Verificar sintaxe
skhd --check-config ~/.skhdrc

# Reiniciar
skhd --restart-service
```

**Configuração não carrega:**
```bash
# Tornar executável
chmod +x ~/.yabairc

# Recarregar
yabai --restart-service
```

### 🔍 Logs e Diagnóstico
```bash
# Logs do sistema
tail -f /tmp/yabai_*.log
tail -f /tmp/skhd_*.log

# Diagnóstico completo
./troubleshoot.sh

# Status dos serviços
launchctl list | grep koekeishiya
```

---

## 🎨 Personalização

### 📝 Editando Configurações
```bash
# Yabai
nano ~/.yabairc

# Skhd
nano ~/.skhdrc

# Aplicar mudanças
yabai --restart-service
skhd --restart-service
```

### 🎯 Exemplos de Customização

**Bordas coloridas:**
```bash
yabai -m config window_border on
yabai -m config window_border_width 2
yabai -m config active_window_border_color 0xff775759
```

**Opacidade de janelas:**
```bash
yabai -m config window_opacity on
yabai -m config active_window_opacity 1.0
yabai -m config normal_window_opacity 0.9
```

**Regras específicas:**
```bash
# Floating para apps específicos
yabai -m rule --add app="System Preferences" manage=off
yabai -m rule --add app="Calculator" manage=off
```

---

## 🔗 Links Úteis

- 📚 **Documentação Yabai**: https://github.com/koekeishiya/yabai
- ⌨️ **Documentação Skhd**: https://github.com/koekeishiya/skhd
- 🍺 **Homebrew**: https://brew.sh
- 🛡️ **Configurações TCC**: Configurações → Privacidade e Segurança

---

## 📞 Suporte

Problemas ou dúvidas:
1. Execute `./troubleshoot.sh`
2. Consulte os logs em `/tmp/yabai_*.log`
3. Verifique as configurações em `~/.yabairc`
4. Teste as permissões de Acessibilidade

**Gabriel Ramos** - Yabal-Ramos Project