# ddev-go - Script di installazione per DDEV

## Descrizione

`ddev-go` è uno script aggiuntivo per DDEV che semplifica la gestione di variabili di ambiente e la configurazione di progetti Drupal. Lo script consente di creare automaticamente un file `ddev.env` che gestisce le variabili di ambiente specifiche per lo sviluppo, e da queste variabili viene generato dinamicamente il file di configurazione `config.yaml` per DDEV.

## Requisiti

Prima di eseguire questo script, assicurati di avere installato:

- **DDEV**: Se non hai DDEV installato, visita la [documentazione ufficiale di DDEV](https://ddev.readthedocs.io/en/stable/) per le istruzioni di installazione.
- **Un progetto Drupal**: Lo script è pensato per progetti di sviluppo Drupal. Può essere utilizzato in qualsiasi ambiente DDEV già configurato con un progetto Drupal esistente o per la configurazione di un nuovo progetto Drupal.
- **Nota per gli utenti Windows**: Se stai utilizzando DDEV su Windows, è necessario eseguire l'installazione da una shell Ubuntu o WSL (Windows Subsystem for Linux). Assicurati di avere Ubuntu o una distribuzione simile installata e aperta prima di eseguire il comando di installazione.


## Installazione

Per installare il pacchetto `ddev-go` sul tuo sistema, puoi eseguire il seguente comando direttamente dal terminale.

1. **Scarica e installa** eseguendo il comando:

```bash
curl -L https://raw.githubusercontent.com/mitchel21/ddev-go/main/install.sh | bash 
```

## Prima installazione di un progetto Drupal in locale già esistente

### `pi`
Package Install.

- **Descrizione**: Avvia il composer install e il npm install(del tema).
- **Esempio**:

```bash
ddev-go pi -s
```

## Opzioni

### `-s` o `--start`
Avvia il progetto DDEV.

- **Descrizione**: Avvia il tuo ambiente DDEV, rendendolo pronto all'uso.
- **Esempio**:

```bash
ddev-go -s
```

### `-r` o `--restart`
Rivvia il progetto DDEV.

- **Descrizione**: Avvia il tuo ambiente DDEV, rendendolo pronto all'uso.
- **Esempio**:

```bash
ddev-go -r
```