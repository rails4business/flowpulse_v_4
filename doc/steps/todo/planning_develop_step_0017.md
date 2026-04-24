# planning_develop_step_0017.md

## Focus

Lo `0017` prende i punti rimasti aperti dopo il consolidamento di dominio e builder fatto nello `0016`.

Qui non si riaprono le basi:

- `Port`
- `Line`
- `Experience`
- `Station`
- `link_station_id`
- `link_port_id`
- `port_entry`

Quelle basi restano valide.

Lo step si concentra su:

- rifinitura del modello station
- completamento della metro map creator
- emersione chiara degli ingressi del port

## Punto 1

### separare davvero posizione nel percorso e tipo di nodo

Nel dominio e' stato fissato che:

- `opening / step / closing`
- `normal / branch / gate`

non sono lo stesso asse.

Correzione importante:

- `opening / step / closing` non va persistito come campo
- e' informazione implicita nella sequenza della line
- si ricava da:
  - `line_id`
  - `position`

Quindi nel `0017` il solo asse da mantenere davvero come dato e':

- `station_kind`

Per esempio:

- `normal`
- `branch`
- `gate`

Nel `0017` questo va tradotto in schema e UI:

- ripulire `station_kind` verso i soli valori semantici del nodo
- non usare piu' un solo enum per tutto
- lasciare `opening / step / closing` come lettura derivata della line

### Obiettivo

Arrivare a una station che possa avere:

- posizione nel percorso letta in modo implicito
- `station_kind` esplicito per il comportamento del nodo

## Punto 2

### usare davvero `port_entry` nella mappa

`Station.port_entry` esiste gia' come dato.

Nel `0017` va reso operativo:

- segno visivo leggero nella `land_map`
- riconoscimento chiaro degli ingressi del port
- eventuale filtro/logica per capire da quali station il port si apre

### Obiettivo

Far emergere che il `Port` inizia da una o piu' station primarie di ingresso.

## Punto 3

### rifinire il nodo condiviso come vero interscambio metro

Nel `0016` la mappa ha gia':

- gruppo condiviso
- piu' pallini interni
- unica label della principale
- linee che passano per i loro punti reali

Nel `0017` resta da rifinire:

- capsula del gruppo ancora piu' aderente ai punti
- resa migliore quando i nodi non sono allineati perfettamente
- intersezioni tra linee diverse piu' chiare sotto il cursore

### Obiettivo

Portare il nodo condiviso verso un interscambio sobrio e leggibile, piu' vicino al riferimento metro.

### Regola grafica fissata

Le station di connessione non vanno rese come simbolo speciale sul singolo record.

Vanno rese come:

- interscambio unico
- pallini membri allineati su un asse semplice
- contorno / dorsale condivisa sobria
- nome visibile solo della station principale

In piu':

- le linee della mappa devono usare le stesse coordinate renderizzate del gruppo condiviso
- quindi ogni linea deve passare davvero per il proprio pallino nel gruppo

### Controllo manuale minimo del gruppo

Prima di un auto-layout globale, il creator deve poter sistemare i nodi condivisi a mano.

Quindi:

- ogni station collegata ha un `link_order`
- la station principale del gruppo ha un `shared_group_angle`

Questo permette di controllare:

- ordine locale dei pallini del gruppo
- asse del gruppo:
  - `horizontal`
  - `vertical`
  - `diagonal_up`
  - `diagonal_down`

## Punto 4

### intersezioni cross-line piu' esplicite nel builder

Nei casi liberi di `Nuova station`, la mappa gia' puo' leggere una station di un'altra line come ampliamento del gruppo condiviso.

Resta da fare meglio:

- evidenziare piu' chiaramente la station candidata
- far capire in anticipo che non si tratta di un punto libero
- distinguere meglio:
  - inserimento sulla stessa line
  - ampliamento del gruppo condiviso

## Punto 5

### drag delle station in modalita' modifica

Quando `Modifica` e' attivo:

- le station devono poter essere trascinate
- il drag deve aggiornare `map_x` / `map_y`
- il gruppo condiviso deve restare coerente anche durante il trascinamento

### Obiettivo

Portare la `land_map` da builder click-based a editor piu' diretto, senza rompere la logica gia' chiusa.

## Ordine Di Lavoro

Ordine consigliato:

1. schema separato per ruolo e tipo nodo
2. emersione di `port_entry` nella mappa
3. rifinitura finale dei nodi condivisi / interscambi
4. intersezioni cross-line piu' leggibili
5. drag in `Modifica`
