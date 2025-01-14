# ddev-go - Script di installazione per DDEV

## Descrizione

`ddev-go` è uno script che facilita l'installazione di uno strumento personalizzato per l'ambiente DDEV. Questo script aggiunge un alias al tuo shell per facilitare l'esecuzione di uno script specifico in DDEV.

## Requisiti

Prima di eseguire questo script, assicurati di avere installato:

- **DDEV**: Se non hai DDEV installato, visita la [documentazione ufficiale di DDEV](https://ddev.readthedocs.io/en/stable/) per le istruzioni di installazione.

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
ddev-go -s
```