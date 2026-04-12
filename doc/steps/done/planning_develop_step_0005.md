# Planning Develop Step 0005

## Stato

Completato.

## Obiettivo chiuso

Lo step 0005 ha introdotto la rete nautica minima tra `Port`.

L'obiettivo era:

- passare da insieme di isole isolate a carta nautica navigabile
- collegare i `Port` senza tornare a un modello ad albero
- separare bene:
  - appartenenza simbolica (`brand_port_id`)
  - collegamento navigabile reale (`SeaRoute`)

## Decisioni fissate

### SeaRoute

`SeaRoute` e' il collegamento nautico minimo tra due `Port`.

Per ora:

- la rotta e' non orientata
- `A -> B` e `B -> A` valgono come stessa rotta
- i due porti devono essere distinti
- i due porti devono appartenere allo stesso `Profile`

Campi minimi usati:

- `profile_id`
- `source_port_id`
- `target_port_id`

### Distinzione semantica

`brand_port_id` non e' una rotta.

Resta:

- bandiera di appartenenza
- area madre simbolica
- riferimento di mondo/brand

`SeaRoute` invece e':

- collegamento reale
- rete navigabile tra porti
- struttura che consente alla carta nautica di diventare attraversabile

## UX chiusa nello step 0005

Quando il creator attiva `Modifica`:

- compaiono i controlli operativi della carta
- sulle isole compare un bottone per iniziare una nuova rotta
- cliccando il bottone su un'isola, quella diventa sorgente della rotta
- compare subito una linea tratteggiata di preview che parte dall'isola
- la linea segue il mouse sul mare
- se il puntatore passa sopra un altro `Port`, la preview si aggancia a quel porto
- se si clicca un altro `Port`, la `SeaRoute` viene creata
- se si clicca il mare, si apre il modal per un nuovo `Port` di destinazione gia' collegato alla sorgente

## Outcome raggiunto

Alla fine dello step 0005 esistono:

- il modello `SeaRoute`
- la persistenza delle rotte tra `Port`
- il rendering delle rotte sulla carta nautica
- la creazione di rotta verso un porto esistente
- la creazione di nuovo porto dal mare gia' collegato alla sorgente
- il dettaglio `show` del singolo `Port`

## File principali coinvolti

- `db/migrate/20260410101500_create_sea_routes.rb`
- `app/models/sea_route.rb`
- `app/models/profile.rb`
- `app/models/port.rb`
- `app/controllers/creator_controller.rb`
- `app/controllers/creator/ports_controller.rb`
- `app/controllers/creator/sea_routes_controller.rb`
- `app/views/creator/carta_nautica.html.erb`
- `app/views/creator/ports/show.html.erb`
- `app/javascript/controllers/sea_chart_controller.js`
- `test/models/sea_route_test.rb`

## Punto aperto lasciato al passo successivo

Con lo step 0005 chiudiamo il livello minimo della rete del mare.

Il passo successivo non e' rendere piu' complessa `SeaRoute`, ma iniziare a collegare il mare con il livello della terra:

- `Trail`
- `Service`
- primi legami tra `Port` e percorso pratico
