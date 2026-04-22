# planning_develop_step_0015.md

## Focus

Lo `0015` non apre nuovi model.

Il focus e':

- far funzionare davvero la `land_map` come metro map creator
- separare i problemi della UI uno per volta
- chiudere prima il flusso `new_line`
- poi chiudere il flusso `new_station`
- solo dopo rifinire `edit_line` e `edit_station`

## Stato Di Partenza

La base dati resta:

- `Port`
- `Line`
- `Experience`
- `Station`

Con queste regole gia' fissate:

- `Line belongs_to :port`
- `Experience belongs_to :port`
- `Station belongs_to :line`
- `Station belongs_to :experience, optional: true`
- `Station` puo' avere:
  - `link_station_id`
  - `link_port_id`
  - `map_x`
  - `map_y`

## Problemi Reali Da Separare

La `land_map` oggi sta provando a fare troppe cose insieme:

- visualizzazione della mappa
- selezione line
- selezione station
- creazione line
- creazione prima station
- aggancio/creazione experience
- modifica line
- modifica station

Questo rende fragile:

- il DOM della pagina
- i target Stimulus
- l'apertura dei modal
- il comportamento con Turbo/cache

Per questo lo `0015` deve isolare i problemi.

## Problema 1

### `new_line` deve funzionare da solo

Flusso corretto:

1. il creator clicca `Modifica`
2. clicca `Aggiungi line`
3. la pagina entra in modalita' piazzamento
4. nessun modal si apre ancora
5. il creator clicca sulla mappa
6. compare il marker del punto scelto
7. si apre il modal centrale `Nuova Line`
8. il creator compila:
   - dati della line
   - prima station
9. salva
10. la line diventa il contesto attivo

### Regole

- il modal non deve aprirsi al click su `Aggiungi line`
- il modal si apre solo dopo il click sulla mappa
- la UX deve essere leggibile anche con mappa vuota
- il flusso va reso robusto anche se Turbo riusa la pagina

## Problema 2

### la prima station nasce con la line

Lo `0015` fissa che:

- creare una `Line` dalla mappa significa creare anche la sua prima `Station`

Per ora il modal `Nuova Line` deve restare essenziale:

- `Line`
  - `name`
  - `line_kind`
  - `color`
- prima `Station`
  - `name`
  - `station_kind`
  - coordinate gia' prese dalla mappa

## Problema 3

### `Experience` va alleggerita nel flusso `new_line`

Nel primo passaggio dello `0015` non bisogna caricare troppo il modal `Nuova Line`.

Scelta consigliata:

- prima far funzionare `Line + first Station`
- poi decidere se:
  - tenere `Experience` anche nel modal `new_line`
  - oppure spostarla in un secondo step

Priorita':

- prima stabilita' del flusso
- poi completezza del form

## Problema 4

### `new_station` va chiuso come flusso separato

Solo dopo `new_line`, il flusso corretto e':

1. il creator seleziona una line oppure una station di una line
2. clicca `Aggiungi station`
3. la pagina entra in modalita' piazzamento
4. nessun modal si apre ancora
5. il creator clicca la mappa
6. compare il marker del punto scelto
7. si apre il modal centrale `Nuova Station`
8. il creator compila:
   - station
   - experience esistente o nuova

### Preview visiva durante `new_station`

Quando `Aggiungi station` e' attivo:

- se e' selezionata una `Station`
  - la preview parte da quella `Station`
- se e' selezionata solo una `Line`
  - la preview parte dall'ultima `Station` della line

Durante il movimento del cursore sulla mappa:

- compare una linea tratteggiata temporanea
- la linea segue il cursore
- il click finale fissa il punto e apre il modal `Nuova Station`

### Regola di selezione in `Modifica`

Quando la pagina e' in `Modifica`:

- il click su una `Line` non deve aprire subito il modal di modifica
- il click su una `Station` non deve aprire subito il modal di modifica
- il click deve prima selezionare il contesto attivo

Poi, solo con azione esplicita, il creator puo':

- aprire `Modifica line`
- aprire `Modifica station`
- cliccare `Aggiungi station`

Regola pratica:

- `Aggiungi station` richiede un contesto attivo
- il contesto puo' essere:
  - una `Line`
  - una `Station` che appartiene a una `Line`
- il modal `Nuova Station` eredita la `Line` attiva

### Azioni esplicite nella toolbar `Modifica`

Dentro `Modifica` devono esserci pulsanti separati per:

- `Modifica line`
- `Modifica station`

Regola:

- se non e' selezionata nessuna `Line`, `Modifica line` resta disattivo
- se non e' selezionata nessuna `Station`, `Modifica station` resta disattivo
- il click sulla mappa continua a servire prima di tutto per selezionare il contesto

### Punto futuro

Da affrontare dopo:

- far partire una nuova `Line` da una `Station` gia' presente su un'altra `Line`

Questo non va ancora implementato nello stesso passaggio di stabilizzazione base.

### UX `Experience` nel modal `new_station`

Per evitare rumore e ambiguita', il modal `Nuova Station` deve avere uno switch semplice:

- `Usa experience esistente`
- `Crea nuova experience`

Regola:

- se il creator sceglie `esistente`
  - compare solo il campo per selezionare una `Experience`
- se il creator sceglie `nuova`
  - compaiono solo:
    - nome nuova experience
    - tipo nuova experience

Per tenere la mappa piu' veloce:

- il campo `Experience esistente` non deve essere una select lunga
- deve usare ricerca/autocompletamento semplice
- la stessa UX va portata anche in `Modifica station`

## Problema 5

### `edit_line` e `edit_station` vengono dopo

Lo `0015` non deve partire da qui.

Prima si chiude:

- `new_line`
- `new_station`

Solo dopo si rifiniscono:

- `edit_line`
- `edit_station`

## Obiettivo UX

La `land_map` deve somigliare sempre di piu' a:

- [`/flowpulse_v_4/mappa_metro.html`](/Users/marcobeffa/CODE_NOW/rails4b_2025/flowpulse_v_4/public/flowpulse_v_4/mappa_metro.html)

Ma il percorso giusto non e':

- aggiungere piu' pannelli

Il percorso giusto e':

- togliere rumore
- rendere affidabile il click
- rendere affidabile il modal
- far capire chiaramente il contesto attivo

## Ordine Operativo

1. chiudere il bug `new_line`
2. rendere stabile `Line + first Station`
3. scegliere quanto tenere `Experience` dentro `new_line`
4. chiudere il bug `new_station`
5. rifinire `edit_line`
6. rifinire `edit_station`

## Criterio Di Chiusura Dello Step

Lo `0015` si potra' chiudere quando:

- `new_line` funziona sempre
- `new_station` funziona sempre
- la mappa resta il centro
- i modal si aprono nel momento giusto
- il creator puo' costruire una line, la prima station, e poi aggiungere le successive senza ambiguita'
