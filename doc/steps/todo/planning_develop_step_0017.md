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

Stato attuale:

- `station_kind` e' stato riallineato verso i soli valori semantici del nodo
- `opening / step / closing` sono letti dalla posizione nella line
- il builder e la mappa non devono piu' reintrodurre i vecchi valori misti

### Obiettivo

Obiettivo raggiunto nel `0017`:

- posizione nel percorso letta in modo implicito
- `station_kind` esplicito per il comportamento del nodo

## Punto 2

### usare davvero `port_entry` nella mappa

`Station.port_entry` esiste gia' come dato.

Stato attuale:

- segno visivo presente nella `land_map`
- presente nei form `Nuova Station` e `Modifica Station`
- resta da rifinire solo la resa grafica del simbolo, non il dato

### Obiettivo

Far emergere meglio che il `Port` inizia da una o piu' station primarie di ingresso.

## Punto 3

### rifinire il nodo condiviso come vero interscambio metro

Nel `0016` la mappa ha gia':

- gruppo condiviso
- piu' pallini interni
- unica label della principale
- linee che passano per i loro punti reali

Nel `0017` resta da rifinire:

- rapporto visivo tra linee e pallini ancora da tarare meglio
- dorsale del gruppo ancora da rendere piu' sobria e aderente ai punti
- resa migliore quando i nodi non sono allineati perfettamente
- disposizione del gruppo coerente con le linee che passano per i suoi punti
- label solo della primaria gia' corretta, da mantenere

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
- evidenziare meglio la station di un'altra line quando il cursore la puo' usare come intersezione

## Punto 6

### station con uscita verso un altro port

Se una station ha `link_port_id`, il nodo rappresenta un'uscita dal `Port` attuale verso un altro `Port`.

Regola fissata:

- `link_port_id` rende la station terminale per la prosecuzione della stessa line nel port corrente
- quindi quella station non deve permettere `Nuova station dopo`
- ma il nodo non viene chiuso come nodo di rete

Quindi una station con `link_port_id` puo' ancora:

- stare dentro un gruppo condiviso
- avere station collegate via `link_station_id`
- far partire una nuova `Line`

In sintesi:

- chiude la stessa line locale
- non blocca biforcazioni, shared group o passaggi di rete

## Punto 5

### drag delle station in modalita' modifica

Stato attuale:

- esiste il tool `Sposta station`
- entra in `move=1`
- permette di trascinare la station selezionata
- se la station e' in un nodo condiviso, sposta tutto il nodo
- salva a fine drag e ricarica la mappa

Resta da fare:

- stato visivo piu' chiaro quando `move=1` e' attivo
- eventuale drag live senza reload finale
- eventuale affinamento del comportamento del drag sui nodi condivisi

### Obiettivo

Portare la `land_map` da builder click-based a editor piu' diretto, senza rompere la logica gia' chiusa.

## Ordine Di Lavoro

Ordine aggiornato:

1. rifinitura finale dei nodi condivisi / interscambi
2. intersezioni cross-line piu' leggibili
3. comportamento delle station con `link_port_id`
4. polish di `move=1`
5. rifinitura visiva di `port_entry`
