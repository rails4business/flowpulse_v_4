# planning_develop_step_0014.md

## Focus

Dopo la chiusura dello `0013`, il passo successivo non e' ridefinire i model base.

Il focus dello `0014` e':

- trasformare la mappa terra creator in una pagina davvero costruibile
- avvicinare l'esperienza creator a una vista tipo `mappa_metro.html`
- introdurre coordinate e logica grafica stabile per `Station`
- preparare il terreno per l'apertura futura ai `professional` sulle `Experience`

## Base Gia' Fissata

La struttura minima resta:

- `Port`
- `Line`
- `Experience`
- `Station`

Con queste regole:

- `Line` e `Station` restano strutture creator
- `Experience` puo' essere aperta anche ai `professional`
- `Station` lega una `Experience` a una `Line`
- `Station` puo' anche avere:
  - `link_station_id`
  - `link_port_id`

## Decisioni Di Modello

Per non aprire troppa complessita' troppo presto, nello `0014` si fissa questa scelta:

- `Station` resta un nodo semplice della `Line`
- `Station` collega una `Experience` principale alla `Line`
- non si apre ancora una join `StationExperience`
- non si apre ancora il nesting delle `Experience`

Quindi, per ora:

- `Line belongs_to :port`
- `Experience belongs_to :port`
- `Station belongs_to :line`
- `Station belongs_to :experience, optional: true`

### Regola Di Responsabilita'

- `Line` = struttura del percorso
- `Station` = nodo/capitolo/tappa visibile
- `Experience` = contenuto o azione che la station apre

La persona e il creator vedono prima la `Station`.

La `Station` poi puo' aprire la sua `Experience`.

## Content

Per tenere il sistema semplice, il `Content` non va distribuito ovunque nello stesso momento.

La scelta iniziale e':

- `Port` ha `Content`
- `Experience` avra' `Content`
- `Station` non ha `Content` nel primo passaggio
- `Line` potra' avere `Content` solo dopo, se servira' una overview editoriale della line

Motivo:

- evitare duplicazione tra `Station` ed `Experience`
- tenere `Station` come nodo di navigazione
- tenere `Experience` come unita' editoriale/operativa

## Pagine Da Avere

Nel primo assetto creator devono esserci chiaramente:

- una pagina con tutte le `Experience` del `Port`
- una pagina con tutte le `Line` del `Port`
- una pagina con le `Station` di una `Line`
- una pagina `land_map` del `Port`

Queste quattro viste sono la base pratica da consolidare prima di aprire altra complessita'.

## Obiettivo Grafico

La destinazione da raggiungere e' una pagina creator simile a:

- [`/flowpulse_v_4/mappa_metro.html`](/Users/marcobeffa/CODE_NOW/rails4b_2025/flowpulse_v_4/public/flowpulse_v_4/mappa_metro.html)

La pagina deve permettere di:

- vedere le linee come binari
- vedere le station come nodi
- leggere gli incroci
- costruire progressivamente la mappa
- usare la mappa come vero spazio di lavoro creator

## Punti Da Fare

### 1. Coordinate delle station

Le `Station` devono avere coordinate proprie per la mappa.

Campi da introdurre:

- `map_x`
- `map_y`

Possibili campi futuri, non ancora obbligatori:

- `label_x`
- `label_y`

Regola:

- se le coordinate esistono, la mappa usa quelle
- se mancano, la mappa puo' usare un layout automatico di fallback

### 2. Form station con posizione

Il form creator delle `Station` deve permettere di impostare:

- `map_x`
- `map_y`

in modo semplice, senza drag and drop nel primo passaggio.

### 3. Mappa terra dinamica

La pagina `land_map` del `Port` deve diventare:

- piu' leggibile
- piu' vicina alla grammatica della metro map
- piu' utile come spazio creator

Prima soglia:

- binari puliti
- station leggibili
- etichette coerenti
- incroci distinguibili
- click sulle station

### 4. Azioni dalla mappa

Dalla pagina mappa terra il creator deve poter:

- aprire una `Line`
- aprire una `Station`
- aggiungere una `Station`
- aggiungere una `Line`
- aprire le `Experience`

Non ancora:

- editor grafico complesso
- drag and drop completo

### 5. Professional e experience

Va fissato il passo successivo sui ruoli:

- `Experience` modificabile anche dai `professional`
- `Line` e `Station` restano `creator`

Questo non va ancora implementato del tutto nello `0014`, ma va preparato con attenzione.

### 6. Webapp sea chart

Il `webapp_sea_chart`, rimandato dal `0013`, resta nello sfondo dello `0014`.

Non e' il primo punto operativo.

Prima viene:

- la mappa terra creator

Poi:

- la costruzione piu' raffinata della mappa mare della `web_app`

## Da Fare Adesso

Nel primo blocco operativo dello `0014`:

- rendere la `land_map` la vera pagina di lavoro creator
- dare piu' spazio alla mappa e meno alle viste elenco
- spostare legenda e supporto in una colonna laterale piu' compatta
- creare le `Line` dalla mappa
- creare la prima `Station` insieme alla `Line`
- creare le `Station` dalla mappa
- permettere, nella creazione station, di:
  - scegliere una `Experience` esistente
  - oppure crearne una nuova

Regola pratica:

- le pagine elenco `Line` e `Station` restano vive
- ma diventano pagine di supporto
- il lavoro principale si sposta sulla `land_map`

### Flusso operativo da fissare nella `land_map`

Per evitare ambiguita' nella UX creator, il processo corretto va fissato cosi':

#### Nuova line

1. il creator clicca `Modifica`
2. clicca `Aggiungi line`
3. la pagina entra in modalita' piazzamento
4. non si apre ancora nessun modal
5. il creator clicca sulla mappa nel punto in cui vuole far partire la line
6. solo dopo il click:
   - compare il marker del punto scelto
   - si apre il modal centrale `Nuova Line`
7. nel modal il creator compila:
   - dati della line
   - prima station
   - experience iniziale
8. dopo il salvataggio:
   - la line esiste
   - la prima station esiste
   - la line puo' essere selezionata
   - da li' si possono aggiungere altre station

#### Nuova station

1. il creator seleziona una line
2. clicca `Aggiungi station`
3. la pagina entra in modalita' piazzamento
4. non si apre ancora nessun modal
5. il creator clicca sulla mappa
6. solo dopo il click:
   - compare il marker del punto scelto
   - si apre il modal centrale `Nuova Station`
7. nel modal il creator compila:
   - dati della station
   - experience esistente o nuova

#### Regole UX da rispettare

- nessun modal deve aprirsi al click su `Aggiungi line`
- nessun modal deve aprirsi al click su `Aggiungi station`
- il modal si apre solo dopo il click sulla mappa
- l'istruzione di piazzamento deve stare sopra la mappa, non come falsa card laterale
- dopo la creazione della prima station, la line diventa il contesto attivo
- da una line attiva il creator puo':
  - aggiungere altre station
  - uscire dalla line
  - selezionare altro

## Da Fare Dopo

Nel blocco successivo, non immediato:

- migliorare la grammatica grafica della metro map
- evidenziare errori e incoerenze direttamente sulla mappa
- aggiungere mini pannelli o modali sulla station
- aprire `Experience` anche ai `professional`
- introdurre drag and drop solo se davvero necessario

Queste cose vengono dopo aver reso la mappa gia' usabile senza editor complesso.

## Ordine Consigliato

1. aggiungere `map_x` e `map_y` a `Station`
2. aggiornare form e model `Station`
3. aggiornare `land_map` per usare coordinate reali
4. aggiungere azioni piu' comode dalla pagina mappa
5. migliorare la resa grafica verso `mappa_metro.html`
6. consolidare l'elenco `Experience` del `Port`
7. preparare l'apertura `Experience` ai `professional`

## Aggiornamento Corrente

Il primo passo successivo e' stato fissato cosi':

- `station_kind` esteso con:
  - `opening`
  - `closing`
- creazione rapida dalla `land_map` piu' chiara:
  - scelta di una `Experience` esistente
  - oppure creazione di una nuova `Experience`
- prima `Station` della `Line` pensata di default come apertura
- `Line` con colore esplicito
- pannelli della `land_map` aperti solo via params:
  - `new_line`
  - `new_station`
  - `edit_line`

## Obiettivo Dello Step

Lo `0014` deve portare a questo risultato:

- una mappa terra creator davvero usabile
- station con coordinate esplicite
- prima grammatica grafica stabile della metro map
- un elenco chiaro delle `Experience` del `Port`
- base pronta per costruzione visuale piu' diretta
