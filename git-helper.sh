#!/bin/bash

# Configurações
VERSION="2.0.0"
ALIAS_NAME="gut"
INSTALL_DIR="$HOME/.git-helper"
BIN_DIR="$HOME/bin"
HIST_FILE="$INSTALL_DIR/git-helper-history.txt"
BACKUP_DIR="$INSTALL_DIR/backups"
MAX_HIST_ITEMS=50
MAX_DISPLAY_ITEMS=10
MAX_BACKUPS=5

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Funções de instalação
install_git_helper() {
    echo -e "${CYAN}Instalando Git Helper para Termux...${NC}"
    
    # Criar diretórios necessários
    mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$BACKUP_DIR"
    
    # Copiar script
    if cp "$0" "$INSTALL_DIR/git-helper.sh"; then
        chmod +x "$INSTALL_DIR/git-helper.sh"
        
        # Criar alias
        echo "alias $ALIAS_NAME='bash $INSTALL_DIR/git-helper.sh'" >> "$HOME/.bashrc"
        
        # Criar link simbólico
        ln -sf "$INSTALL_DIR/git-helper.sh" "$BIN_DIR/$ALIAS_NAME"
        
        # Configurar git
        setup_git_config
        
        echo -e "${GREEN}Instalação concluída com sucesso!${NC}"
        echo -e "${YELLOW}Reinicie o Termux ou execute: source ~/.bashrc${NC}"
        echo -e "${CYAN}Agora você pode usar o comando '${ALIAS_NAME}' para iniciar o Git Helper${NC}"
    else
        echo -e "${RED}Falha na instalação. Verifique as permissões.${NC}"
        exit 1
    fi
}

setup_git_config() {
    echo -e "${CYAN}Configuração inicial do Git${NC}"
    
    # Verificar se já existe configuração
    if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
        echo -e "${GREEN}Configuração do Git já existe:${NC}"
        echo -e "Nome: $(git config --global user.name)"
        echo -e "Email: $(git config --global user.email)"
        return
    fi
    
    echo -e "${YELLOW}Por favor, configure seu usuário Git global${NC}"
    echo -e "${CYAN}Exemplo de email:${NC}"
    echo -e "1. SeuEmail@gmail.com"
    echo -e "2. 123456+SeuUsuario@users.noreply.github.com"
    
    read -p "Digite seu nome completo: " name
    read -p "Digite seu email Git: " email
    
    git config --global user.name "$name"
    git config --global user.email "$email"
    
    # Configurações adicionais recomendadas
    git config --global credential.helper store
    git config --global push.default simple
    git config --global pull.rebase false
    
    echo -e "${GREEN}Configuração Git concluída!${NC}"
}

# Funções auxiliares
show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗"
    echo -e "║${BLUE}  GIT HELPER v$VERSION - TERMUX         ${CYAN}║"
    echo -e "║${BLUE}  Digite '${ALIAS_NAME}' em qualquer lugar   ${CYAN}║"
    echo -e "╚══════════════════════════════════════════╝${NC}"
    echo -e "Diretório atual: ${YELLOW}$(pwd)${NC}"
    echo
}

show_menu() {
    show_header
    echo -e "${CYAN}┌─────────────────── MENU ───────────────────┐"
    echo -e "│ 1. ${GREEN}Criar pasta/repositório${CYAN}               │"
    echo -e "│ 2. ${GREEN}Clonar repositório${CYAN}                    │"
    echo -e "│ 3. ${GREEN}Enviar alterações (push)${CYAN}              │"
    echo -e "│ 4. ${GREEN}Atualizar repositório (pull)${CYAN}          │"
    echo -e "│ 5. ${GREEN}Remover arquivo/pasta${CYAN}                 │"
    echo -e "│ 6. ${GREEN}Mover arquivos/pastas${CYAN}                 │"
    echo -e "│ 7. ${GREEN}Ver histórico de repositórios${CYAN}         │"
    echo -e "│ 8. ${GREEN}Criar backup do repositório${CYAN}           │"
    echo -e "│ 9. ${GREEN}Restaurar backup${CYAN}                      │"
    echo -e "│ 10. ${GREEN}Configurações do Git${CYAN}                 │"
    echo -e "│ 11. ${RED}Sair${CYAN}                                │"
    echo -e "└────────────────────────────────────────────┘${NC}"
    echo -ne "${YELLOW}Escolha uma opção [1-11]: ${NC}"
}

input_prompt() {
    echo -ne "${YELLOW}$1${NC}"
}

success_msg() {
    echo -e "${GREEN}$1${NC}"
}

error_msg() {
    echo -e "${RED}$1${NC}"
}

warning_msg() {
    echo -e "${YELLOW}$1${NC}"
}

info_msg() {
    echo -e "${CYAN}$1${NC}"
}

press_any_key() {
    echo -ne "${MAGENTA}Pressione qualquer tecla para continuar...${NC}"
    read -n 1 -s -r
    echo
}

confirm_action() {
    local prompt="$1"
    echo -ne "${YELLOW}$prompt (s/n): ${NC}"
    read -r response
    [[ "$response" =~ ^[sSyY]$ ]]
}

progress_bar() {
    local duration=${1:-0.05}
    echo -n "Processando "
    for i in {1..20}; do
        echo -n "▉"
        sleep "$duration"
    done
    echo
}

create_backup() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/${repo_name}_${timestamp}.zip"
    
    if [ ! -d "$repo_path/.git" ]; then
        error_msg "Não é um repositório Git válido para backup."
        return 1
    fi
    
    info_msg "Criando backup de $repo_name..."
    
    if zip -r "$backup_file" "$repo_path" >/dev/null; then
        success_msg "Backup criado: $(basename "$backup_file")"
        
        # Limitar número de backups
        ls -t "$BACKUP_DIR"/*.zip | tail -n +$((MAX_BACKUPS+1)) | xargs rm -f
    else
        error_msg "Falha ao criar backup."
    fi
}

# Funções principais
criar_pasta() {
    show_header
    info_msg "─── CRIAÇÃO DE PASTA/REPOSITÓRIO ───"
    input_prompt "Digite o nome da pasta: "
    read -r nome
    
    if [ -d "$nome" ]; then
        warning_msg "A pasta '$nome' já existe."
    else
        if mkdir -p "$nome"; then
            success_msg "Pasta '$nome' criada com sucesso!"
            
            if confirm_action "Deseja transformar em um repositório Git?"; then
                cd "$nome" || return
                git init
                success_msg "Repositório Git inicializado em '$nome'!"
                
                if confirm_action "Deseja criar um arquivo README.md?"; then
                    echo "# $nome" > README.md
                    git add README.md
                    git commit -m "Initial commit with README"
                    success_msg "README.md criado e commit realizado!"
                fi
                cd ..
            fi
            
            if confirm_action "Deseja entrar na pasta criada?"; then
                cd "$nome" || return
                success_msg "Você está agora em: $(pwd)"
            fi
        else
            error_msg "Falha ao criar a pasta '$nome'."
        fi
    fi
    press_any_key
}

clonar() {
    show_header
    info_msg "─── CLONAR REPOSITÓRIO ───"
    
    if [ -s "$HIST_FILE" ]; then
        info_msg "Repositórios recentes:"
        tail -n $MAX_DISPLAY_ITEMS "$HIST_FILE" | nl -ba -w 3 -s '. '
        echo
    fi
    
    input_prompt "Cole a URL do repositório Git ou digite o número acima: "
    read -r entrada

    if [[ "$entrada" =~ ^[0-9]+$ ]]; then
        url=$(sed -n "${entrada}p" "$HIST_FILE")
        if [ -z "$url" ]; then
            error_msg "Número inválido."
            press_any_key
            return 1
        fi
    else
        url="$entrada"
    fi

    repo_name=$(basename "$url" .git)
    info_msg "Clonando repositório: $url"
    
    progress_bar 0.05
    if git clone "$url"; then
        echo "$url" >> "$HIST_FILE"
        success_msg "Repositório clonado com sucesso!"
        
        # Criar backup automático
        if confirm_action "Deseja criar um backup inicial do repositório?"; then
            create_backup "$repo_name"
        fi
        
        if confirm_action "Deseja entrar na pasta do repositório clonado?"; then
            cd "$repo_name" || return
            success_msg "Você está agora em: $(pwd)"
        fi
    else
        error_msg "Falha ao clonar o repositório."
    fi
    
    press_any_key
}

enviar() {
    show_header
    info_msg "─── ENVIAR ALTERAÇÕES (PUSH) ───"
    
    input_prompt "Digite o caminho até o repositório (ou . para atual): "
    read -r caminho
    
    if ! cd "$caminho" 2>/dev/null; then
        error_msg "Diretório inválido."
        press_any_key
        return 1
    fi
    
    info_msg "Diretório atual: $(pwd)"
    echo
    
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        error_msg "Este diretório não é um repositório Git."
        press_any_key
        return 1
    fi
    
    info_msg "╔═ Status do repositório:"
    git status
    echo
    
    input_prompt "Digite uma mensagem para o commit: "
    read -r mensagem
    
    info_msg "╔═ Adicionando alterações..."
    git add . || {
        error_msg "Falha ao adicionar alterações."
        press_any_key
        return 1
    }
    
    info_msg "╔═ Criando commit..."
    git commit -m "$mensagem" || {
        error_msg "Falha ao criar commit."
        press_any_key
        return 1
    }
    
    info_msg "╔═ Enviando alterações..."
    if git push; then
        success_msg "Alterações enviadas com sucesso!"
        
        if confirm_action "Deseja criar um backup do repositório?"; then
            create_backup "$(pwd)"
        fi
    else
        error_msg "Falha ao enviar alterações."
    fi
    
    press_any_key
}

atualizar() {
    show_header
    info_msg "─── ATUALIZAR REPOSITÓRIO (PULL) ───"
    
    input_prompt "Digite o caminho até o repositório (ou . para atual): "
    read -r caminho
    
    if ! cd "$caminho" 2>/dev/null; then
        error_msg "Diretório inválido."
        press_any_key
        return 1
    fi
    
    info_msg "Diretório atual: $(pwd)"
    echo
    
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        error_msg "Este diretório não é um repositório Git."
        press_any_key
        return 1
    fi
    
    info_msg "╔═ Atualizando repositório..."
    if git pull; then
        success_msg "Repositório atualizado com sucesso!"
    else
        error_msg "Falha ao atualizar o repositório."
    fi
    
    press_any_key
}

remover() {
    show_header
    info_msg "─── REMOVER ARQUIVO/PASTA ───"
    
    input_prompt "Digite o nome do arquivo ou pasta para remover: "
    read -r alvo
    
    if [ ! -e "$alvo" ]; then
        error_msg "Arquivo/pasta '$alvo' não encontrado."
        press_any_key
        return 1
    fi
    
    if confirm_action "Tem certeza que deseja remover '$alvo'?"; then
        if rm -rf "$alvo"; then
            success_msg "'$alvo' removido com sucesso."
        else
            error_msg "Falha ao remover '$alvo'."
        fi
    else
        warning_msg "Operação cancelada."
    fi
    
    press_any_key
}

mover() {
    show_header
    info_msg "─── MOVER ARQUIVOS/PASTAS ───"
    
    info_msg "Conteúdo do diretório atual:"
    ls -p --color=auto | grep -v "/$" | nl -ba -w 3 -s '. '
    echo
    ls -p --color=auto | grep "/$" | nl -ba -w 3 -s '. ' | sed 's/$/\//'
    echo
    
    input_prompt "Digite o nome do arquivo/pasta que deseja mover: "
    read -r origem
    
    if [ ! -e "$origem" ]; then
        error_msg "O item '$origem' não existe."
        press_any_key
        return 1
    fi
    
    info_msg "Pastas disponíveis:"
    find . -maxdepth 1 -type d ! -path . | sed 's|^\./||' | nl -ba -w 3 -s '. '
    echo
    
    input_prompt "Digite o nome da pasta de destino (ou 'nova' para criar): "
    read -r destino
    
    if [ "$destino" == "nova" ]; then
        input_prompt "Digite o nome da nova pasta: "
        read -r destino
        if ! mkdir -p "$destino"; then
            error_msg "Falha ao criar pasta '$destino'."
            press_any_key
            return 1
        fi
        success_msg "Pasta '$destino' criada."
    fi
    
    if [ ! -d "$destino" ]; then
        error_msg "Pasta de destino '$destino' não existe."
        press_any_key
        return 1
    fi
    
    if mv "$origem" "$destino/"; then
        success_msg "'$origem' movido para '$destino/' com sucesso!"
    else
        error_msg "Falha ao mover '$origem'."
    fi
    
    press_any_key
}

ver_historico() {
    show_header
    info_msg "─── HISTÓRICO DE REPOSITÓRIOS ───"
    
    if [ ! -s "$HIST_FILE" ]; then
        warning_msg "Nenhum repositório no histórico."
    else
        nl -ba -w 3 -s '. ' "$HIST_FILE" | tail -n $MAX_DISPLAY_ITEMS
    fi
    
    press_any_key
}

criar_backup() {
    show_header
    info_msg "─── CRIAR BACKUP ───"
    
    input_prompt "Digite o caminho do repositório para backup (ou . para atual): "
    read -r caminho
    
    if ! cd "$caminho" 2>/dev/null; then
        error_msg "Diretório inválido."
        press_any_key
        return 1
    fi
    
    create_backup "$(pwd)"
    press_any_key
}

restaurar_backup() {
    show_header
    info_msg "─── RESTAURAR BACKUP ───"
    
    if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        error_msg "Nenhum backup disponível."
        press_any_key
        return 1
    fi
    
    info_msg "Backups disponíveis:"
    ls -lt "$BACKUP_DIR" | grep -v '^total' | nl -ba -w 3 -s '. ' | awk '{print $1, $9}'
    echo
    
    input_prompt "Digite o número do backup para restaurar: "
    read -r num
    
    backup_file=$(ls -t "$BACKUP_DIR" | sed -n "${num}p")
    
    if [ -z "$backup_file" ]; then
        error_msg "Número inválido."
        press_any_key
        return 1
    fi
    
    info_msg "Restaurando backup: $backup_file"
    
    # Extrair para uma pasta temporária primeiro
    temp_dir=$(mktemp -d)
    if unzip "$BACKUP_DIR/$backup_file" -d "$temp_dir" >/dev/null; then
        # Mover para o diretório atual
        mv "$temp_dir"/* .
        rmdir "$temp_dir"
        success_msg "Backup restaurado com sucesso!"
    else
        error_msg "Falha ao restaurar backup."
    fi
    
    press_any_key
}

config_git() {
    show_header
    info_msg "─── CONFIGURAÇÕES DO GIT ───"
    
    echo -e "${CYAN}Configuração atual:${NC}"
    echo -e "Nome: $(git config --global user.name || echo 'Não configurado')"
    echo -e "Email: $(git config --global user.email || echo 'Não configurado')"
    echo
    
    echo -e "${CYAN}Opções:${NC}"
    echo -e "1. ${GREEN}Alterar nome e email${NC}"
    echo -e "2. ${GREEN}Visualizar todas as configurações${NC}"
    echo -e "3. ${GREEN}Voltar ao menu principal${NC}"
    echo
    
    input_prompt "Escolha uma opção [1-3]: "
    read -r opcao
    
    case $opcao in
        1)
            setup_git_config
            ;;
        2)
            git config --global --list
            ;;
        3)
            return
            ;;
        *)
            error_msg "Opção inválida."
            ;;
    esac
    
    press_any_key
}

# Menu principal
main_menu() {
    # Verificar se o git está instalado
    if ! command -v git &>/dev/null; then
        error_msg "Git não está instalado. Instale com: pkg install git"
        exit 1
    fi
    
    # Se receber --install como argumento, instalar
    if [ "$1" == "--install" ]; then
        install_git_helper
        exit 0
    fi
    
    # Inicializar se for a primeira execução
    mkdir -p "$INSTALL_DIR" "$BACKUP_DIR"
    touch "$HIST_FILE"
    
    while true; do
        show_menu
        read -r opcao
        
        case $opcao in
            1) criar_pasta ;;
            2) clonar ;;
            3) enviar ;;
            4) atualizar ;;
            5) remover ;;
            6) mover ;;
            7) ver_historico ;;
            8) criar_backup ;;
            9) restaurar_backup ;;
            10) config_git ;;
            11)
                info_msg "Saindo... Até logo!"
                exit 0
                ;;
            *)
                error_msg "Opção inválida! Tente novamente."
                sleep 1
                ;;
        esac
    done
}

# Ponto de entrada
if [ "$0" = "$BASH_SOURCE" ]; then
    main_menu "$@"
fi
