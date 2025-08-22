# 🪟 Yabal-Ramos

> **Instalação automatizada de Yabai + Skhd para macOS**

![macOS](https://img.shields.io/badge/macOS-Monterey%2B-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-yellow.svg)

**Yabal-Ramos** é um conjunto de scripts que automatiza completamente a instalação e configuração do [Yabai](https://github.com/koekeishiya/yabai) (tiling window manager) e [Skhd](https://github.com/koekeishiya/skhd) (hotkey daemon) no macOS.

## ✨ Características

- 🚀 **Instalação com um comando** - Setup completo automatizado
- 🔐 **Configuração de permissões** - TCC automation + manual fallback
- 🛠️ **Troubleshooting integrado** - Diagnóstico e correção automática
- 📋 **Configurações prontas** - Setup otimizado out-of-the-box
- 🩺 **Health checks** - Verificação contínua do sistema

## 🚀 Instalação Rápida

```bash
# Clone o repositório
git clone https://github.com/seunome/yabal-ramos.git
cd yabal-ramos

# Execute a instalação
chmod +x install.sh
./install.sh

# Configure permissões (escolha uma opção)
sudo ./auto-grant-accessibility.sh   # Automático
# OU
./grant-accessibility.sh             # Manual
```

## 📦 O que é instalado

### 🏗️ Componentes Principais
- **[Yabai](https://github.com/koekeishiya/yabai)** - Tiling window manager
- **[Skhd](https://github.com/koekeishiya/skhd)** - Simple hotkey daemon
- **Homebrew** - Package manager (se não estiver instalado)

### ⚙️ Configurações Criadas
- `~/.yabairc` - Configuração do window manager
- `~/.skhdrc` - Atalhos de teclado
- LaunchAgents para auto-start dos serviços

### 🔐 Permissões Configuradas
- Accessibility permissions via TCC database
- Fallback para configuração manual via System Preferences

## 📋 Scripts Incluídos

| Script | Descrição |
|--------|-----------|
| `install.sh` | 🔧 Instalador principal - setup completo |
| `grant-accessibility.sh` | 🔐 Configuração manual de permissões |
| `auto-grant-accessibility.sh` | ⚡ Configuração automática via TCC |
| `troubleshoot.sh` | 🩺 Diagnóstico e solução de problemas |

## 🎮 Uso Básico

### 🔄 Gerenciar Serviços
```bash
# Iniciar
yabai --start-service
skhd --start-service

# Reiniciar
yabai --restart-service
skhd --restart-service

# Parar
yabai --stop-service
skhd --stop-service
```

### 📊 Consultas Úteis
```bash
# Listar espaços
yabai -m query --spaces

# Listar janelas
yabai -m query --windows

# Status do sistema
./troubleshoot.sh
```

### ⌨️ Atalhos Padrão
- `cmd + alt + r` - Reiniciar Yabai
- `cmd + alt + space` - Toggle floating window
- `cmd + alt + h/j/k/l` - Navegar entre janelas
- `cmd + shift + h/j/k/l` - Mover janelas

## 🔧 Personalização

### 📝 Editando Configurações
```bash
# Yabai
nano ~/.yabairc

# Skhd  
nano ~/.skhdrc

# Aplicar mudanças
yabai --restart-service && skhd --restart-service
```

### 🎨 Exemplos de Customização
```bash
# Bordas coloridas
yabai -m config window_border on
yabai -m config active_window_border_color 0xff775759

# Gaps personalizados
yabai -m config window_gap 10
yabai -m config top_padding 20

# Regras específicas
yabai -m rule --add app="System Preferences" manage=off
```

## 🚨 Troubleshooting

### ❌ Problemas Comuns

**Yabai não responde:**
```bash
./troubleshoot.sh
sudo yabai --load-sa
```

**Permissões negadas:**
```bash
./grant-accessibility.sh
# Adicionar manualmente nas Configurações do Sistema
```

**Skhd não funciona:**
```bash
skhd --check-config ~/.skhdrc
skhd --restart-service
```

### 📋 Diagnóstico Completo
```bash
./troubleshoot.sh
```

## 🔍 Logs e Debug

```bash
# Logs em tempo real
tail -f /tmp/yabai_*.log
tail -f /tmp/skhd_*.log

# Status dos serviços
launchctl list | grep koekeishiya
```

## 📚 Documentação

- 📖 **[Manual Completo](MANUAL.md)** - Guia detalhado de uso
- 🔗 **[Yabai Wiki](https://github.com/koekeishiya/yabai/wiki)** - Documentação oficial
- ⌨️ **[Skhd Examples](https://github.com/koekeishiya/skhd/blob/master/examples/skhdrc)** - Exemplos de configuração

## 🔗 Compatibilidade

- ✅ **macOS Monterey** (12.0+)
- ✅ **macOS Ventura** (13.0+)  
- ✅ **macOS Sonoma** (14.0+)
- ✅ **macOS Sequoia** (15.0+)

### 🏗️ Arquiteturas
- ✅ **Apple Silicon** (M1/M2/M3)
- ✅ **Intel** (x86_64)

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/amazing-feature`)
3. Commit suas mudanças (`git commit -m 'Add amazing feature'`)
4. Push para a branch (`git push origin feature/amazing-feature`)
5. Abra um Pull Request

## 👨‍💻 Autor

**Gabriel Ramos**
- 🐙 GitHub: [@seunome](https://github.com/seunome)
- 📧 Email: seuemail@exemplo.com

## 🙏 Agradecimentos

- [koekeishiya](https://github.com/koekeishiya) - Criador do Yabai e Skhd
- Comunidade macOS - Feedback e contribuições
- [Homebrew](https://brew.sh) - Package management

---

⭐ **Gostou do projeto? Deixe uma estrela!**