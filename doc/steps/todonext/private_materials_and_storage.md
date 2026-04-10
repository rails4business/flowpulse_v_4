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

- `Active Storage`
- storage oggetti esterno

Per esempio:

- Hetzner Object Storage

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

## Da chiarire dopo

- quali contenuti restano nel repo
- quali contenuti passano in `Active Storage`
- se i markdown privati vanno salvati come blob allegati oppure come testo database
- politica di accesso:
  - pubblico
  - creator
  - professional
  - viaggiatore iscritto
