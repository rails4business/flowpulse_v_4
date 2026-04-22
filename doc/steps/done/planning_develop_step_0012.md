# planning_develop_step_0012.md

## 🎯 Obiettivo

Partire dal primo modello concreto utile al brand e alla web app:

- `Content`

prima di entrare davvero in:

- `Experience`
- `Journey`
- `Line`

e tenere questo step concentrato su:

- `Content`
- `Port`
- home standard della web app

## Perche' si parte da Content

Senza `Content` restano troppo vuoti:

- `Port`
- home della web app
- materiali iniziali del brand
- schede, note, testi, immagini, media

Quindi il primo passo reale dello step `0012` e':

- creare `Content`

## Comando iniziale

```bash
bin/rails g model Content profile:references contentable:references{polymorphic} title:string slug:string description:text content:text mermaid:text banner_url:string thumb_url:string horizontal_cover_url:string vertical_cover_url:string url_media_content:string meta:jsonb visibility:integer published_at:datetime
```

## Idea del modello

`Content` e' il contenuto principale di un oggetto.

La forma iniziale corretta e':

- `Content belongs_to :contentable, polymorphic: true`

e lato modelli:

- `Port has_one :content, as: :contentable`
- `Line has_one :content, as: :contentable`
- `Journey has_one :content, as: :contentable`
- `Experience has_one :content, as: :contentable`

Questo permette un accesso semplice come:

- `port.content`
- `line.content`
- `journey.content`
- `experience.content`

## Campi iniziali di Content

Per questa prima fase, `Content` tiene:

- `title`
- `slug`
- `description`
- `content`
- `mermaid`
- `banner_url`
- `thumb_url`
- `horizontal_cover_url`
- `vertical_cover_url`
- `url_media_content`
- `meta`
- `visibility`
- `published_at`

## Pubblicazione e visibilita'

La direzione da fissare e' questa:

- la pubblicazione editoriale vive su `Content`
- non va duplicata ovunque su tutti i modelli strutturali

Quindi:

- `visibility`
- `published_at`

stanno su `Content`.

## Sequenza pratica da seguire

La sequenza da seguire nello `0012` e':

1. creare `Content`
2. collegarlo subito almeno a `Port`
3. correggere `Port` come step successivo dello stesso `0012`

## Stato attuale gia' applicato

I primi passi concreti dello step sono gia' stati portati nel codice:

- `Content` e' stato creato come modello polimorfico
- `Port` e' stato collegato con `has_one :content`
- nello show creator del `Port` ora si puo':
  - aggiungere il contenuto
  - modificare il contenuto
  - vedere una preview del contenuto principale
- la pubblicazione pubblica del `Port` ora legge da:
  - `content.visibility`
  - `content.published_at`
- e non piu' da `Port.visibility`
- il form creator del `Port` non gestisce piu' la visibilita'
- e' stata preparata anche la migration per rimuovere da `ports`:
  - `visibility`
  - `published_at`

## Correzione di Port

`Port` oggi ha ancora una logica precedente.

La direzione nuova e':

- `Port` e' davvero completo solo quando ha il suo `Content`
- il contenuto principale del port vive in `port.content`
- la pubblicazione editoriale deve tendere a vivere su `Content`

Quindi, dopo aver creato `Content`, bisogna:

- collegarlo a `Port`
- riallineare `Port` al rapporto `has_one :content`
- ridurre progressivamente la duplicazione tra stato del modello e stato editoriale

La direzione concreta fissata ora e':

- `Port` e' struttura
- `Content` e' contenuto editoriale principale
- la visibilita' pubblica sta su `Content`
- il pubblico vede il `Port` solo se il suo `Content` e' davvero pubblico

## Regola futura per tutti gli altri

Questa non vale solo per `Port`.

La stessa regola dovra' poi valere anche per:

- `Line`
- `Journey`
- `Experience`

Quindi la direzione architetturale da fissare e':

- ogni oggetto principale ha un solo `Content` principale
- il modello strutturale resta piu' neutro
- il contenuto editoriale e la pubblicazione vivono su `Content`

## Soglia concreta del brand

Questo passaggio serve anche a sostenere una soglia reale del brand e della web app:

- una home della web app
- materiali iniziali
- schede
- testi e media
- primi contenuti pubblicabili

Per arrivare poi a:

- `Experience`
- `Journey`
- `Line`
- servizi
- percorsi
- blog come `Line`
- libri come `Line`

ma senza partire da strutture vuote.

## Hub operativo per ora

L'hub operativo non va caricato subito di logiche definitive.

Per ora la scelta da fissare e':

- visibile solo se `user.superadmin == true`
- usato come playground di view
- alimentato con dati mock:
  - `json`
  - `yml`
- senza aprire nuovi modelli applicativi in questo step

Questo permette di:

- provare l'interfaccia
- manovrare facilmente i contenuti
- evitare di bloccare lo sviluppo su schema e migrazioni premature

## Confine dello step 0012

Lo `0012` resta focalizzato su:

- `Content`
- integrazione con `Port`
- pubblicazione tramite `Content`
- home standard della web app
- hub operativo solo come test UI superadmin

Non e' il posto in cui chiudere ora:

- `Event`
- `Line`
- `Journey`
- blog runtime
- book runtime
- importer markdown

## Passi successivi gia' da fissare

Dopo `Content`, lo step `0012` dovra' affrontare almeno questi nodi immediatamente successivi.

### 1. Event

Serve fissare gli `Event` almeno come primo modello operativo del professionista.

Da chiarire:

- quali sono gli eventi minimi
- se sono:
  - pubblici
  - privati
- a quale:
  - brand
  - web app
  - perimetro locale
  appartengono

Da tenere presente:

- l'evento non e' di tutta `Flowpulse`
- l'evento vive dentro un brand / una web app

### 2. Contenuto dell'evento

Piu' avanti l'evento andra' collegato a un contenuto vivo, inteso come:

- `Experience`
- oppure `Stage`

ma questo collegamento va chiarito dopo il primo passo su `Content`.

### 3. Avanzamento del percorso

Serve prevedere che:

- alcuni eventi facciano parte di un percorso
- il sistema possa tracciare l'avanzamento
- il percorso possa essere:
  - di apprendimento
  - terapeutico
  - di benessere
  - o altro

Questo nodo va tenuto presente anche prima di chiudere il modello finale del `Journey`.

### 4. Slot e prenotazioni

Va fissato anche il tema delle prenotazioni per i professionisti.

Da chiarire:

- se servono slot liberi
- quali spazi dare alle prenotazioni
- come collegare slot, evento, servizio e professionista

Questo tema non va implementato ancora, ma va tenuto sotto lo stesso step come nodo vicino agli eventi.

### 5. Valore economico

Vanno distinti almeno questi livelli di valore:

- valore del servizio del professionista
- valore del servizio del percorso
- valore dello spazio
- valore del contenuto

In piu' va tenuto presente anche:

- il valore riconosciuto alla segreteria
- il valore riconosciuto a chi porta il cliente

Questo non va deciso subito, ma va segnato perche' cambia molto il modo in cui saranno pensati:

- servizi
- percorsi
- professionisti
- prenotazioni
- referral

### 6. Tipi di contenuto caricabili

Va tenuto presente che piu' avanti il sistema dovra' permettere di caricare e gestire:

- blog come `Line`
- libri come `Line`
- lezioni
- percorsi
- altri contenuti simili

Da fissare meglio piu' avanti:

- i post del blog come tappe della `Line`
- le pagine o i capitoli del libro come tappe della `Line`

Questo conferma che `Content` e' il primo passo giusto, ma non l'ultimo.

## Spostamento operativo agli step successivi

Per mantenere semplice la struttura:

- i modelli successivi passano allo `0013`
  - `Event`
  - `Line`
  - `Journey`
  - relazioni principali

- il resto piu' avanzato passa allo `0014`
  - servizi
  - materiali importati
  - storage privato
  - pricing e valore
  - slot e prenotazioni

Quindi il prossimo lavoro concreto dello `0012` resta:

- definire bene la home standard della web app
