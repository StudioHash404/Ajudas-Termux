# Git Helper para Termux 🧠🐧

Um assistente interativo para facilitar o uso do Git no **Termux**, totalmente colorido e intuitivo! Com menus e recursos como backup, histórico de repositórios, commits rápidos e mais.

---

## 🚀 Funcionalidades

- Criar pastas e repositórios Git
- Clonar repositórios (com histórico e seleção)
- Commit e push simplificado
- Pull / atualização de repositório
- Remover e mover arquivos/pastas com confirmações
- Histórico de repositórios clonados
- Criar e restaurar backups (`.zip`) com limite de versões
- Configurar o Git (nome, e-mail, preferências)
- Alias `gut` para executar de qualquer lugar

---

## 🧩 Requisitos

- **Termux** instalado  
- **Git**:  
  ```bash
  pkg install git
  ```
- **zip/unzip** (para backup):  
  ```bash
  pkg install zip unzip
  ```
- **bash** (já vem no Termux por padrão)

---

## 📥 Como instalar

1. **Clone este repositório**:
   ```bash
   git clone https://github.com/StudioHash404/Ajudas-Termux.git
   cd Ajudas-Termux
   ```

2. **Copie e torne o script executável**:
   ```bash
   cp git-helper.sh ~/.git-helper/git-helper.sh
   chmod +x ~/.git-helper/git-helper.sh
   ```

3. **Instalação automatizada**:
   Rode o instalador com:
   ```bash
   ~/.git-helper/git-helper.sh --install
   ```

   Isso fará:
   - Criação de pastas: `~/.git-helper`, `~/bin`, `~/.git-helper/backups`
   - Cópia e permissão do script
   - Criação do alias `gut`
   - Link `~/bin/gut`
   - Configuração inicial do Git (nome(ou usuário), e-mail, credenciais)

4. **Ative o alias**:
   ```bash
   source ~/.bashrc
   ```

---

## ✅ Uso

Agora basta executar:

```bash
gut
```

E navegar por um menu simples e colorido com todas as opções disponíveis.

---

## 🛠 Comandos diretos (alternativa ao alias)

Se o alias não funcionar:

```bash
bash ~/.git-helper/git-helper.sh
```
