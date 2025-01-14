#!/bin/bash

# Colori per messaggi
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Directory di installazione globale
DDEV_GLOBAL_SCRIPTS_DIR="$HOME/.ddev/scripts"

# Nome dello script
SCRIPT_NAME="ddev-go"

# Funzione per verificare se DDEV è installato
check_ddev_installed() {
  if ! command -v ddev &> /dev/null; then
    echo -e "${RED}Errore: DDEV non è installato. Installalo prima di procedere.${RESET}"
    exit 1
  fi
}

# Funzione per creare la directory globale se non esiste
create_scripts_directory() {
  if [ ! -d "$DDEV_GLOBAL_SCRIPTS_DIR" ]; then
    echo -e "${YELLOW}Creazione della directory globale DDEV...${RESET}"
    mkdir -p "$DDEV_GLOBAL_SCRIPTS_DIR" || {
      echo -e "${RED}Errore: impossibile creare la directory $DDEV_GLOBAL_SCRIPTS_DIR.${RESET}"
      exit 1
    }
    echo -e "${GREEN}Directory $DDEV_GLOBAL_SCRIPTS_DIR creata con successo.${RESET}"
  fi
}

# Funzione per scaricare il file ddev-go.sh
download_script() {
  echo -e "${YELLOW}Scaricando il file ddev-go.sh...${RESET}"
  curl -L https://raw.githubusercontent.com/mitchel21/ddev-go/main/ddev-go.sh -o "$DDEV_GLOBAL_SCRIPTS_DIR/$SCRIPT_NAME" || {
    echo -e "${RED}Errore durante il download del file ddev-go.sh.${RESET}"
    exit 1
  }
  chmod +x "$DDEV_GLOBAL_SCRIPTS_DIR/$SCRIPT_NAME" || {
    echo -e "${RED}Errore durante l'impostazione dei permessi eseguibili.${RESET}"
    exit 1
  }
  echo -e "${GREEN}File ddev-go.sh scaricato con successo!${RESET}"
}

# Funzione per aggiungere l'alias allo script
configure_alias() {
  # Definiamo la riga dell'alias
  ALIAS_LINE="alias ddev-go='$DDEV_GLOBAL_SCRIPTS_DIR/$SCRIPT_NAME'"
  COMMENT_LINE="# Alias per ddev-go"

  BASHRC="$HOME/.bashrc"
  ZSHRC="$HOME/.zshrc"

  # Controlla se l'alias è già presente in .bashrc
  if ! grep -qxF "$ALIAS_LINE" "$BASHRC"; then
    # Aggiungi il commento e l'alias se non presenti
    echo "$COMMENT_LINE" >> "$BASHRC"
    echo "$ALIAS_LINE" >> "$BASHRC"
    echo -e "${GREEN}Alias e commento aggiunti a $BASHRC.${RESET}"
  else
    echo -e "${YELLOW}Alias già presente in $BASHRC.${RESET}"
  fi

  # Controlla se l'alias è già presente in .zshrc (se esiste)
  if [ -f "$ZSHRC" ] && ! grep -qxF "$ALIAS_LINE" "$ZSHRC"; then
    # Aggiungi il commento e l'alias se non presenti
    echo "$COMMENT_LINE" >> ""
    echo "$COMMENT_LINE" >> "$ZSHRC"
    echo "$ALIAS_LINE" >> "$ZSHRC"
    echo -e "${GREEN}Alias e commento aggiunti a $ZSHRC.${RESET}"
  elif [ -f "$ZSHRC" ]; then
    echo -e "${YELLOW}Alias già presente in $ZSHRC.${RESET}"
  fi

  # Istruzioni per applicare l'alias
  echo -e "${YELLOW}Per applicare immediatamente l'alias, esegui:${RESET} source ~/.bashrc o source ~/.zshrc"
}


# Funzione per mostrare istruzioni di fine installazione
print_success_message() {
  echo -e "${GREEN}Installazione completata con successo!${RESET}"
  echo -e "Puoi ora usare il comando ${BLUE}ddev-go${RESET} per avviare lo script."
}

# Inizio dello script
echo -e "${BLUE}Inizio installazione di $SCRIPT_NAME...${RESET}"

check_ddev_installed
create_scripts_directory
download_script
configure_alias
print_success_message
