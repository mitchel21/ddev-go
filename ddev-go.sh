#!/bin/bash

# Informazioni sullo script
SCRIPT_NAME="ddev-go"
VERSION="1.0.0"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Percorso del file ddev.env
ENV_FILE=".ddev/ddev.env"

# Definizione dei comandi validi e loro abbreviazioni
declare -A COMMAND_ALIASES
COMMAND_ALIASES[start]="s"
COMMAND_ALIASES[restart]="r"
COMMAND_ALIASES[config]="c"

# Mappa delle opzioni valide per ogni comando
declare -A VALID_OPTIONS
VALID_OPTIONS[start]="pi"
VALID_OPTIONS[restart]="pi"
VALID_OPTIONS[config]=""

COMMAND="$1"
OPTIONS=()

# Funzione per mostrare la versione
show_version() {
  echo "$SCRIPT_NAME version $VERSION"
}

# Funzione per mostrare l'help
show_help() {
  echo "$SCRIPT_NAME version $VERSION"
  echo -e "${GREEN}Uso dello script:${RESET}"
  echo -e "  ./ddgo [comando] [opzioni]"
  echo -e ""
  echo -e "${BLUE}Comandi disponibili:${RESET}"
  echo -e "  start, s       Avvia l'ambiente DDEV."
  echo -e "  restart, r     Riavvia l'ambiente DDEV."
  echo -e "  config, c      Modifica il file ddev.env."
  echo -e ""
  echo -e "${BLUE}Opzioni per start/restart:${RESET}"
  echo -e "  pi             Installa le dipendenze tramite Composer e NPM."
  echo -e ""
  echo -e "${BLUE}Generale:${RESET}"
  echo -e "  -h, --help     Mostra questo messaggio di aiuto."
  echo -e "  -v, --version  Mostra la versione dello script."
}

# Funzione per controllare se DDEV è inizializzato
check_ddev_initialized() {
  # Inizio dello script
  echo -e "${BLUE}Controllo ambiente...${RESET}"

  if [ ! -f ".ddev/config.yaml" ]; then
    echo -e "${RED}DDEV non è inizializzato nel progetto corrente.${RESET}"
    read -p "Vuoi Inizializzare DDEV? (s/n): " CHOICE
      if [[ "$CHOICE" =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}Eseguendo la configurazione guidata di DDEV...${RESET}"
        ddev config || { echo -e "${RED}Errore durante la configurazione di DDEV.${RESET}"; exit 1; }
        echo -e "${GREEN}DDEV configurato con successo!${RESET}"
      else
        exit 0
      fi
  else
    echo -e "${GREEN}DDEV è già inizializzato.${RESET}"
  fi
}

# Funzione per mostrare l'anteprima del file ddev.env
show_env_preview() {
  echo -e "${BLUE}Anteprima del file ddev.env:${RESET}"
  if [ -f "$ENV_FILE" ]; then
    cat "$ENV_FILE"
  else
    echo -e "${RED}Il file $ENV_FILE non esiste.${RESET}"
  fi
}

# Funzione per creare il file ddev.env se mancante
create_env_file_if_missing() {
  if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Il file $ENV_FILE non esiste.${RESET}"
    read -p "Vuoi Creare il file ddev.env? (s/n): " MODIFY
        if [[ "$MODIFY" =~ ^[Ss]$ ]]; then
          create_env_file
        else
          exit 0
        fi
  else
    echo -e "${GREEN}Il file $ENV_FILE esiste già.${RESET}"
  fi
}

# Funzione per creare il file ddev.env guidato
create_env_file() {
  echo -e "${YELLOW}Creazione guidata del file ddev.env:${RESET}"

  # Usa awk per estrarre i valori dal file YAML
  DDEV_PROJECT_NAME=$(awk '/^name:/ { print $2 }' .ddev/config.yaml)
  DDEV_PHP_VERSION=$(awk '/^php_version:/ { gsub("\"", "", $2); print $2 }' .ddev/config.yaml)
  DDEV_WEBSERVER_TYPE=$(awk '/^webserver_type:/ { print $2 }' .ddev/config.yaml)
  DDEV_DOCROOT=$(awk '/^docroot:/ { print $2 }' .ddev/config.yaml)
  DDEV_DATABASE_TYPE=$(awk '/^database:/ {getline; print $2}' .ddev/config.yaml)
  DDEV_DATABASE_VERSION=$(awk '/^database:/ {getline; getline; gsub("\"", "", $2); print $2}' .ddev/config.yaml)
  DDEV_COMPOSER_VERSION=$(awk '/^composer_version:/ { gsub("\"", "", $2); print $2 }' .ddev/config.yaml)
  DDEV_THEME_ACTIVE=$DDEV_PROJECT_NAME
  DDEV_THEME_ACTIVE_COMPILE=true

  # Mostra l'anteprima dei valori letti
  echo -e "${BLUE}Anteprima dei valori config.yaml predefiniti:${RESET}"
  echo -e "Nome progetto: ${GREEN}$DDEV_PROJECT_NAME${RESET}"
  echo -e "Versione PHP: ${GREEN}$DDEV_PHP_VERSION${RESET}"
  echo -e "Server web: ${GREEN}$DDEV_WEBSERVER_TYPE${RESET}"
  echo -e "Percorso root del progetto: ${GREEN}$DDEV_DOCROOT${RESET}"
  echo -e "Tipo database: ${GREEN}$DDEV_DATABASE_TYPE${RESET}"
  echo -e "Versione database: ${GREEN}$DDEV_DATABASE_VERSION${RESET}"
  echo -e "Versione Composer: ${GREEN}$DDEV_COMPOSER_VERSION${RESET}"
  echo -e "Tema attivo: ${GREEN}$DDEV_PROJECT_NAME${RESET}"
  echo -e "Compilazione del tema attivo (in watch): ${GREEN}true${RESET}"

  # Chiedi se si vogliono modificare i valori
  read -p "Vuoi modificare i valori predefiniti? (s/n): " MODIFY_VALUES

  if [[ "$MODIFY_VALUES" =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Premi [Invio] per confermare ogni valore o modifica il valore come desiderato:${RESET}"

    read -p "Nome del progetto (default: $DDEV_PROJECT_NAME): " INPUT_PROJECT_NAME
    DDEV_PROJECT_NAME=${INPUT_PROJECT_NAME:-$DDEV_PROJECT_NAME}

    read -p "Versione PHP (default: $DDEV_PHP_VERSION): " INPUT_PHP_VERSION
    DDEV_PHP_VERSION=${INPUT_PHP_VERSION:-$DDEV_PHP_VERSION}

    read -p "Server web (default: $DDEV_WEBSERVER_TYPE): " INPUT_WEBSERVER_TYPE
    DDEV_WEBSERVER_TYPE=${INPUT_WEBSERVER_TYPE:-$DDEV_WEBSERVER_TYPE}

    read -p "Percorso root del progetto (default: $DDEV_DOCROOT): " INPUT_DOCROOT
    DDEV_DOCROOT=${INPUT_DOCROOT:-$DDEV_DOCROOT}

    read -p "Tipo di database (default: $DDEV_DATABASE_TYPE): " INPUT_DATABASE_TYPE
    DDEV_DATABASE_TYPE=${INPUT_DATABASE_TYPE:-$DDEV_DATABASE_TYPE}

    read -p "Versione del database (default: $DDEV_DATABASE_VERSION): " INPUT_DATABASE_VERSION
    DDEV_DATABASE_VERSION=${INPUT_DATABASE_VERSION:-$DDEV_DATABASE_VERSION}

    read -p "Versione di Composer (default: $DDEV_COMPOSER_VERSION): " INPUT_COMPOSER_VERSION
    DDEV_COMPOSER_VERSION=${INPUT_COMPOSER_VERSION:-$DDEV_COMPOSER_VERSION}

    read -p "Inserisci il nome del tema attivo (default: $DDEV_PROJECT_NAME): " INPUT_THEME_ACTIVE
    DDEV_THEME_ACTIVE=${INPUT_THEME_ACTIVE:-$DDEV_PROJECT_NAME}

    read -p "Abilitare il watch della compilazione del tema attivo (true/false, default: true): " INPUT_THEME_ACTIVE_COMPILE
    DDEV_THEME_ACTIVE_COMPILE=${INPUT_THEME_ACTIVE_COMPILE:-true}
  else
    echo -e "${GREEN}Valori predefiniti confermati.${RESET}"
  fi

  # Genera il file ddev.env con i valori definitivi
  cat <<EOF > "$ENV_FILE"
DDEV_PROJECT_NAME=$DDEV_PROJECT_NAME
DDEV_PHP_VERSION=$DDEV_PHP_VERSION
DDEV_WEBSERVER_TYPE=$DDEV_WEBSERVER_TYPE
DDEV_DOCROOT=$DDEV_DOCROOT
DDEV_DATABASE_TYPE=$DDEV_DATABASE_TYPE
DDEV_DATABASE_VERSION=$DDEV_DATABASE_VERSION
DDEV_COMPOSER_VERSION=$DDEV_COMPOSER_VERSION
DDEV_THEME_ACTIVE=$DDEV_THEME_ACTIVE
DDEV_THEME_ACTIVE_COMPILE=$DDEV_THEME_ACTIVE_COMPILE
EOF

  echo -e "${GREEN}File ddev.env creato con successo!${RESET}"
}

# Funzione per modificare il file ddev.env passo passo
edit_env_file() {
  echo -e "${YELLOW}Modifica guidata del file ddev.env:${RESET}"

  # Verifica se il file esiste
  if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}File ddev.env non trovato! Creando un nuovo file.${RESET}"
    create_env_file
    return
  fi

  # Carica il file .env esistente
  source "$ENV_FILE"

  echo -e "${YELLOW}Premi [Invio] per confermare ogni valore o modifica il valore come desiderato:${RESET}"

  read -p "Nome del progetto (current: $DDEV_PROJECT_NAME): " INPUT_PROJECT_NAME
  DDEV_PROJECT_NAME=${INPUT_PROJECT_NAME:-$DDEV_PROJECT_NAME}

  read -p "Versione PHP (current: $DDEV_PHP_VERSION): " INPUT_PHP_VERSION
  DDEV_PHP_VERSION=${INPUT_PHP_VERSION:-$DDEV_PHP_VERSION}

  read -p "Server web (current: $DDEV_WEBSERVER_TYPE): " INPUT_WEBSERVER_TYPE
  DDEV_WEBSERVER_TYPE=${INPUT_WEBSERVER_TYPE:-$DDEV_WEBSERVER_TYPE}

  read -p "Percorso root del progetto (current: $DDEV_DOCROOT): " INPUT_DOCROOT
  DDEV_DOCROOT=${INPUT_DOCROOT:-$DDEV_DOCROOT}

  read -p "Tipo di database (current: $DDEV_DATABASE_TYPE): " INPUT_DATABASE_TYPE
  DDEV_DATABASE_TYPE=${INPUT_DATABASE_TYPE:-$DDEV_DATABASE_TYPE}

  read -p "Versione del database (current: $DDEV_DATABASE_VERSION): " INPUT_DATABASE_VERSION
  DDEV_DATABASE_VERSION=${INPUT_DATABASE_VERSION:-$DDEV_DATABASE_VERSION}

  read -p "Versione di Composer (current: $DDEV_COMPOSER_VERSION): " INPUT_COMPOSER_VERSION
  DDEV_COMPOSER_VERSION=${INPUT_COMPOSER_VERSION:-$DDEV_COMPOSER_VERSION}

  read -p "Nome del tema attivo (current: $DDEV_THEME_ACTIVE): " INPUT_THEME_ACTIVE
  DDEV_THEME_ACTIVE=${INPUT_THEME_ACTIVE:-$DDEV_THEME_ACTIVE}

  read -p "Abilitare il watch della compilazione del tema attivo (true/false, current: $DDEV_THEME_ACTIVE_COMPILE): " INPUT_THEME_ACTIVE_COMPILE
  DDEV_THEME_ACTIVE_COMPILE=${INPUT_THEME_ACTIVE_COMPILE:-$DDEV_THEME_ACTIVE_COMPILE}



  # Genera di nuovo il file ddev.env con i nuovi valori
  cat <<EOF > "$ENV_FILE"
DDEV_PROJECT_NAME=$DDEV_PROJECT_NAME
DDEV_PHP_VERSION=$DDEV_PHP_VERSION
DDEV_WEBSERVER_TYPE=$DDEV_WEBSERVER_TYPE
DDEV_DOCROOT=$DDEV_DOCROOT
DDEV_DATABASE_TYPE=$DDEV_DATABASE_TYPE
DDEV_DATABASE_VERSION=$DDEV_DATABASE_VERSION
DDEV_COMPOSER_VERSION=$DDEV_COMPOSER_VERSION
DDEV_THEME_ACTIVE=$DDEV_THEME_ACTIVE
DDEV_THEME_ACTIVE_COMPILE=$DDEV_THEME_ACTIVE_COMPILE
EOF

  echo -e "${GREEN}File ddev.env modificato con successo!${RESET}"
}



# Funzione per compilare il file yaml
compile_yaml() {
  # Carica le variabili dal file ddev.env
  set -a
  source "$ENV_FILE"
  set +a

  # Ottieni user.name e user.email da Git locale (opzionale, se lo vuoi fare automaticamente)
  GIT_USER_NAME=$(git config --global user.name)
  GIT_USER_EMAIL=$(git config --global user.email)

  # Percorso del file config.yaml
  CONFIG_FILE=".ddev/config.yaml"

# Genera il file config.yaml
cat <<EOF > "$CONFIG_FILE"
name: $DDEV_PROJECT_NAME
type: php
docroot: $DDEV_DOCROOT
php_version: "$DDEV_PHP_VERSION"
webserver_type: $DDEV_WEBSERVER_TYPE
xdebug_enabled: false
database:
  type: $DDEV_DATABASE_TYPE
  version: "$DDEV_DATABASE_VERSION"
composer_version: "$DDEV_COMPOSER_VERSION"
hooks:
  post-start:
        - exec: composer config --global repositories.messagegroup composer https://\${SATIS_DOMAIN}/d8
        - exec: composer config --global http-basic.\${SATIS_DOMAIN} \${SATIS_USER} \${SATIS_PASSWORD}
        - exec: git config --global user.name "$GIT_USER_NAME"
        - exec: git config --global user.email "$GIT_USER_EMAIL"
        - exec: git config --global credential.helper store
        - exec: touch ~/.git-credentials
        - exec: touch ~/.bashrc
        - exec: echo "cd /var/www/html/docroot" >> ~/.bashrc
        - exec: echo "https://\${BITBUCKET_USER}:\${BITBUCKET_APP_PASSWORD}@bitbucket.org" >> ~/.git-credentials
        - exec: sudo apt-get update
        - exec: sudo apt-get -y install poppler-utils
        - exec: sudo apt-get -y install vim zsh
        - exec: touch ~/.zshrc
        - exec: wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - | zsh || true
        - exec: echo 'alias ll="ls -l"' >> ~/.zshrc
        - exec: echo 'alias l="ls -lah"' >> ~/.zshrc
        - exec: echo 'alias alc="cd /var/www/html/$DDEV_DOCROOT/themes/custom/$DDEV_THEME_ACTIVE && npm i"' >> ~/.zshrc
        - exec: echo 'alias guc="cd /var/www/html/$DDEV_DOCROOT/themes/custom/$DDEV_THEME_ACTIVE && gulp"' >> ~/.zshrc
        - exec: echo 'alias guw="cd /var/www/html/$DDEV_DOCROOT/themes/custom/$DDEV_THEME_ACTIVE && gulp sass"' >> ~/.zshrc
        - exec: echo 'alias drush="/var/www/html/docroot/vendor/bin/drush"' >> ~/.zshrc
        - exec: echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
        - exec: echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
        - exec: sed -i 's/plugins=(git)/plugins=(git composer)/' ~/.zshrc
        - exec: echo 'exec zsh' >> ~/.bashrc
        - exec: npm install -g fontello-cli
EOF

# Comando "pi" (Composer e NPM install)
if [[ " ${OPTIONS[@]} " =~ " pi " ]]; then
  DOCROOT_TRIMMED=${DDEV_DOCROOT%/web}
  cat <<EOF >> "$CONFIG_FILE"
        - exec: cd /var/www/html/$DOCROOT_TRIMMED && composer install
        - exec: cd /var/www/html/$DDEV_DOCROOT/themes/custom/$DDEV_THEME_ACTIVE && npm install
EOF
fi

# Esegui compilazione solo se DDEV_COMPILE è true
if [ "$DDEV_THEME_ACTIVE_COMPILE" == "true" ]; then
    cat <<EOF >> "$CONFIG_FILE"
        - exec: cd /var/www/html/$DDEV_DOCROOT/themes/custom/$DDEV_THEME_ACTIVE && npx gulp
EOF
  else
      echo -e "${YELLOW}Compilazione del tema attivo disabilitata: la variabile DDEV_COMPILE è disabilitata.${RESET}"
  fi

  # Esegui il comando di avvio (se specificato)
  for arg in "$@"; do
    case $arg in
      -s)
        START_COMMAND="ddev start"
        ;;
      -r)
        START_COMMAND="ddev restart"
        ;;
    esac
  done

  # Notifica la generazione del file
  echo -e "${GREEN}File config.yaml generato con successo in $CONFIG_FILE.${RESET}"
}

# Controllo dei comandi
check_commands(){
  while [[ $# -gt 0 ]]; do
    case $1 in
      --version|-v)
        show_version
        exit 0
        ;;
      --help|-h)
        COMMAND="help"
        ;;
      -pi|--package-install)
        OPTIONS+=("pi")
        ;;
      # Comandi diretti o abbreviazioni
      start|restart|config|s|r|c)
        if [[ -n "$COMMAND" ]]; then
          echo -e "${RED}Errore: Più comandi specificati. Usa un solo comando alla volta.${RESET}"
          exit 1
        fi
        # Traduzione abbreviazione in comando
        for CMD in "${!COMMAND_ALIASES[@]}"; do
          if [[ "$1" == "$CMD" || "$1" == "${COMMAND_ALIASES[$CMD]}" ]]; then
            COMMAND="$CMD"
            break
          fi
        done
        ;;
      *)
        echo -e "${RED}Errore: Comando o opzione sconosciuto '$1'. Usa 'help' per l'elenco dei comandi.${RESET}"
        exit 1
        ;;
    esac
    shift
  done
  echo "$COMMAND"
  # Verifica comando valido
  if [[ -z "$COMMAND" ]]; then
    echo -e "${RED}Errore-tttttt: Nessun comando specificato. Usa '--help' per l'elenco dei comandi.${RESET}"
    exit 1
  fi
}

# Esecuzione dei comandi
execute_commands() {
  case $COMMAND in
    help)
      show_help
      exit 0
      ;;
    start)
      check_ddev_initialized
      create_env_file_if_missing
      compile_yaml
      ddev start
      if [[ " ${OPTIONS[@]} " =~ " pi " ]]; then
        echo -e "${BLUE}Installazione dipendenze con Composer e NPM...${RESET}"
        composer install && npm install
      fi
      ;;
    restart)
      check_ddev_initialized
      create_env_file_if_missing
      compile_yaml
      echo -e "${BLUE}Riavvio di DDEV...${RESET}"
      ddev restart
      if [[ " ${OPTIONS[@]} " =~ " pi " ]]; then
        echo -e "${BLUE}Installazione dipendenze con Composer e NPM...${RESET}"
        composer install && npm install
      fi
      ;;
    config)
      check_ddev_initialized
      create_env_file_if_missing
      show_env_preview
      edit_env_file
      ;;
  esac
}

start_script(){
  # Controllo dei comandi
  check_commands
  # Esecuzione dei comandi
  execute_commands
}

start_script
