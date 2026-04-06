# Valore Servizi e Professionisti

## Punto da fissare

Nel dominio Flowpulse non basta distinguere solo:

- journey
- servizio
- ruolo

Va chiarito anche che il valore finale di una erogazione puo' dipendere da piu' livelli contemporaneamente.

## Livelli da distinguere

### 1. Percorso o pacchetto

Definisce cosa viene offerto.

Esempi:

- `igiene posturale`
- percorso salute
- percorso business
- percorso formazione

Qui sta il valore del contenuto e della struttura del percorso.

### 2. Servizio o modalita' di erogazione

Definisce come il percorso viene erogato.

Esempi:

- individuale
- gruppo
- in studio
- online
- 8 persone
- 60 minuti
- 4 incontri

Qui sta il valore della modalita' di erogazione.

### 3. Ruolo

Definisce la funzione che una persona svolge nel servizio.

Esempi:

- guida
- tutor
- insegnante
- segreteria
- operatore

Il ruolo da solo non basta a definire il valore professionale reale.

### 4. Professione

Definisce l'identita' professionale riconosciuta di chi eroga.

Esempi:

- fisioterapista
- medico
- consulente
- insegnante

La professione e' diversa dal ruolo.

Una persona puo' avere:

- una professione riconosciuta
- un ruolo operativo dentro uno specifico servizio

### 5. Qualificazione professionale

Definisce il livello reale di competenza della persona.

Questa parte puo' dipendere da:

- titoli
- formazione esterna validata
- anni di esperienza
- metodiche conosciute
- corsi di aggiornamento
- competenze specialistiche

Questa dimensione rende un professionista piu' o meno quotato, anche a parita' di ruolo e professione.

## Classi di contesto o intensita'

Va fissato anche un asse ulteriore che puo' cambiare il valore del servizio e il tipo di professionista necessario.

Prime classi da considerare:

- `rosso`
- `verde`
- `blu`

Interpretazione iniziale:

- `rosso`
  - casi con maggiore complessita' o responsabilita'
  - esempio: patologia o trattamento delicato

- `verde`
  - benessere, mantenimento, supporto leggero

- `blu`
  - educazione, formazione, prevenzione, apprendimento guidato

Queste classi dovranno essere chiarite meglio in futuro, ma vanno gia' fissate come parte del dominio.

## Esempio concreto

`Igiene posturale`

puo' essere letta cosi':

- percorso/pacchetto: `igiene posturale`
- modalita' servizio: `gruppo in studio`
- partecipanti: `8 persone`
- professione di chi eroga: `fisioterapista`
- classe del contesto: `rosso`, `verde` o `blu`
- qualificazione: metodiche, esperienza, aggiornamenti

Un fisioterapista capace di trattare anche casi `rossi`, con molte formazioni e metodiche, esprime un valore maggiore rispetto a:

- una erogazione orientata solo al benessere `verde`
- una erogazione educativa `blu`
- una figura con minore qualificazione specialistica

## Conseguenza di dominio

Il valore finale non dipende da un solo fattore.

Puo' dipendere dalla combinazione tra:

- valore del percorso
- valore della modalita' di erogazione
- ruolo nel servizio
- professione di chi eroga
- qualificazione professionale
- classe del contesto

## Conseguenza futura sul prezzo

In futuro il prezzo potra' essere:

- unico
- oppure composto da piu' parti

Per esempio:

- valore del pacchetto
- valore del servizio
- quota professionista
- maggiorazione per classe di contesto

## Decisioni aperte

Da chiarire in futuro:

- se chiamare l'offerta principale `servizio` o `pacchetto`
- come rappresentare la professione distinta dal ruolo
- come rappresentare la qualificazione professionale
- come usare le classi `rosso`, `verde`, `blu`
- come sommare o separare il valore del percorso e il valore del professionista

## Nota di progetto

Questa parte va tenuta ferma a livello di dominio.

Non va ancora implementata come:

- pricing engine
- modello definitivo professionale
- calcolo automatico del valore
- classificazione clinica o tecnica completa
