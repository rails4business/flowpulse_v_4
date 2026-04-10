# Planning Develop Step 0003

## Stato

Completato.

## Stato attuale

- esiste gia' una base pubblica e autenticata
- la distinzione `creator / professionista / persona` e' piu' chiara
- il vecchio tentativo ad albero puro con `Searoute` e' stato fermato
- esiste una reference legacy in:
  - `doc/legacy_flowpulse_v3/`

## Step chiuso

Lo step attuale riguarda solo `Port`.

Qui sta emergendo un punto piu' strutturale:

- il mare
- la terra

La distinzione e' questa:

- il mare riguarda struttura, approdi, mondi, organizzazione
- la terra riguarda esperienza pratica, percorso vissuto, journey, tappe, lavoro concreto

Per questo `Port` va pensato come concetto del mare, non della terra.

## Ipotesi di base

### Port

`Port` e' il nodo di attracco.
Non e' una rotta.
Non e' ancora un journey.
E' il punto stabile nella carta nautica del creator.

### Mare

Il mare riguarda cio' che organizza e orienta.

Qui possono stare:

- aree
- mondi
- contenuti
- raccolte
- mappe

### Terra

La terra riguarda cio' che viene vissuto nella pratica.

Qui entrano dopo:

- `Journey`
- `EventDate`
- tappe
- servizi
- lezioni
- trattamenti

## Tipi iniziali di Port

I tipi iniziali di `Port` possono essere:

- `brand`
- `map`
- `blog`
- `book`

## Nota aperta

Da chiarire bene:

- se `folder` ha ancora senso
- se `list` va tenuto come tipo generico
- oppure se e' meglio distinguere direttamente:
  - `blog`
  - `book`

Per ora il problema non e' chiudere tutti i tipi finali.
Il problema e' capire che `Port` non coincide con il percorso pratico.

## Brand come area

Sta emergendo che `brand` non e' solo un'etichetta.
Puo' essere un'area o mondo principale.

Per supportare adeguatamente questa struttura, abbiamo deciso che `Port` avra' da subito un riferimento stabile:

- `brand_port_id`

come foreign key opzionale verso un altro `Port` principale di appartenenza. Questo evita di usare pattern "ad albero" complessi, ma permette di legare in modo semantico e semplice ogni mondo (`map`, `blog`, `book`) al suo brand principale.

## Map e pratica

I `Port` di tipo `map` sono importanti perche' aprono la parte pratica.

Li' poi potranno entrare:

- `Journey`
- tappe
- programmi
- obiettivi

Ma questo passaggio viene dopo.

## Distinzione futura per Journey

Quando entreranno i `Journey`, potranno essere:

- `standard`
  - programma

- `personalized`
  - obiettivo

- `mixed`
  - programma + obiettivo

## Distinzione futura per Event e Activity

`Event` e `Activity` non fanno ancora parte di questo step.

Pero' l'intuizione da fermare e' importante:

- l'`Event` e' condiviso
- l'`Activity` e' personale
- l'`Activity` puo' rappresentare la partecipazione concreta di una persona a un `Event`
- possono avere una scheda che spiega la tappa o il servizio
- possono contenere un resoconto
- possono rappresentare:
  - trattamento
  - lezione
  - online
  - singolo
  - gruppo

Questa parte pero' va tenuta fuori dal primo step operativo su `Port`.

## Cosa e' stato fissato

- fissare `Port` come nodo del mare
- non confondere `Port` con `Journey`
- non confondere `Port` con `Event` o `Activity`
- mantenere `brand`, `map`, `blog` e `book` come tipi iniziali (tramite enum integer)
- confermare l'uso di `brand_port_id` per gerarchie piatte
- aggiungere indice univoco `[profile_id, slug]`
- progettare e generare lo schema minimo definito di `Port`

## Schema minimo definitivo di Port

Campi iniziali:

- `profile_id` (rif. al creator)
- `brand_port_id` (rif. opzionale a port genitore/brand)
- `name`
- `slug` (con indice unico con `profile_id`)
- `port_kind` (enum int: `brand`, `map`, `blog`, `book`)
- `visibility` (enum int: `draft`, `published`, `private`)
- `description`
- `x` e `y` (coordinate per mappe visuali future)
- `meta` (jsonb per estensioni libere)
- `published_at`

Comando per la generazione:

```bash
bin/rails generate model Port \
  profile:references \
  brand_port:references \
  name:string \
  slug:string:index \
  port_kind:integer \
  visibility:integer \
  description:text \
  x:integer \
  y:integer \
  meta:jsonb \
  published_at:datetime
```

*Nota:* Nel file di migrazione verrà specificato un indice unico per `[profile_id, slug]` ed eventuali default.

## Outcome raggiunto

Alla fine di questo step devono essere chiari:

- il significato esatto di `Port`
- la differenza tra mare e terra
- il fatto che `Port` appartiene al livello del mare
- il fatto che `Journey`, `Event` e `Activity` appartengono al livello della terra
- i tipi iniziali davvero sensati di `Port`

---

## Addendum: Procedura per inserire un nuovo Tipo di Port (`port_kind`)

Se in futuro si vorranno estendere i tipi di approdo (es. aggiungere `podcast`, `community`, `course`), andranno modificati esattamente due file chiave:

1. **Il Modello DB (`app/models/port.rb`)**
   Aggiungere il nuovo elemento all'enum `port_kind`, stando molto attenti ad assegnare un nuovo "integer" univoco senza modificare quello dei precedenti (per non sfalsare i dati già salvati a DB).
   ```ruby
   enum :port_kind, { brand: 0, map: 1, blog: 2, book: 3, community: 4 }
   ```

2. **La Libreria Araldica Visiva (`app/views/creator/carta_nautica.html.erb`)**
   Nel ciclo in cui renderizziamo i nodi della carta nautica, esiste uno `switch case` che assegna la "spilletta" o "segnaposto" corretto.
   Andrà creato il nuovo "when" definendo l'icona e le proprietà CSS in-line che ne definiscono la forma (es. tondo, massiccio, sottile, ombreggiato):
   ```ruby
   when "community"
     icon, color, shape_css = "🏕️", "#8b5cf6", "border-radius: 50%; border: 4px dashed #a78bfa; background: #ede9fe; width: 100px; height: 100px;"
   ```
   Questa combinazione renderà automaticamente il nuovo tipo di nodo disponibile nei form e lo disegnerà con la sua forma unica sulla plancia della mappa.
