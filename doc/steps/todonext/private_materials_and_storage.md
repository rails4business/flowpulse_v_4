# Materiali Privati e Storage

## Problema

Se la repository resta pubblica, non e' corretto caricare direttamente nel repo:

- libri
- dispense
- file markdown privati
- immagini private
- materiali riservati ai percorsi o ai professionisti

## Punto da chiarire

Il codice puo' stare in una repository pubblica.
I contenuti privati no.

Per questo serve separare:

- repository pubblica del progetto
- storage applicativo dei contenuti privati

## Direzione possibile

Una direzione coerente e' usare:

- database come fonte operativa
- repository privata per i sorgenti editoriali
- storage oggetti esterno per gli asset binari
- `Active Storage` come livello applicativo di accesso ai file

Per esempio:

- Hetzner Object Storage

## Architettura da fissare

Separare in modo netto:

- repository GitHub pubblica
  - solo applicazione
  - codice
  - niente materiali sensibili
  - niente asset privati

- repository GitHub privata
  - sorgenti editoriali
  - `index.yml`
  - capitoli `*.md`
  - materiali di lavoro
  - archivio leggibile e versionabile

- storage privato su Hetzner
  - immagini
  - video
  - PDF
  - asset pesanti
  - allegati e materiali binari

- database applicativo
  - fonte operativa della web app
  - contenuti runtime
  - stato pubblico/privato
  - collegamenti tra contenuti, port, percorsi e materiali

## Regola operativa

La web app non dovrebbe leggere i file markdown live dalla repository.

Questo vale in particolare per contenuti che andranno modellati come:

- `Line` di tipo blog
- `Line` di tipo book

e dove le unita' interne diventeranno tappe della line:

- post
- pagine
- capitoli

La direzione corretta e':

- import da sorgenti `.md` / `index.yml`
- salvataggio nel database
- uso del database come runtime principale
- archivio dei sorgenti mantenuto separatamente

Quindi:

- `.md` come formato di archivio/import-export
- DB come fonte della web app
- object storage come sede degli asset

## Importer in development

In sviluppo ha senso preparare un importer che prenda:

- `index.yml`
- cartella con `capitolo_**.md`
- eventuali asset collegati

e crei:

- record nel database
- collegamenti corretti tra contenuti e modelli
- file salvati nello storage scelto

Questa strada e' migliore del leggere i file direttamente in produzione.

## Ipotesi

`Active Storage` puo' diventare il livello giusto per gestire:

- PDF
- libri
- dispense
- immagini
- allegati riservati
- anche file markdown se un giorno devono uscire dal repository

## Vantaggi

- il repository puo' restare pubblico
- i materiali privati non finiscono su GitHub
- i file possono avere regole di accesso diverse
- si apre una strada piu' seria per:
  - percorsi privati
  - corsi
  - materiali professionali
  - immagini protette

## Nota

I file markdown pubblici del blog possono anche restare nel repo finche' sono editoriali e pubblici.

I file markdown privati o materiali di percorso invece vanno pensati come contenuti applicativi, non come file di repository.

## Accesso privato ai file

Lo storage privato deve essere accessibile:

- dall'applicazione
- in modo autenticato
- senza esporre direttamente i file come pubblici

Quindi i file privati non vanno serviti con URL pubblici fissi come scelta base.

La direzione giusta e':

- bucket/container privato
- credenziali lato server
- accesso mediato dall'app
- oppure URL firmati a tempo se serve download diretto

## Da chiarire dopo

- quali contenuti restano nel repo
- quali contenuti passano in `Active Storage`
- se i markdown privati vanno salvati come blob allegati oppure come testo database
- politica di accesso:
  - pubblico
  - creator
  - professional
  - viaggiatore iscritto
