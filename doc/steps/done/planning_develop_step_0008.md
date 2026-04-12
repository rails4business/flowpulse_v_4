# Planning Develop Step 0008

## Stato

Completato.

## Obiettivo

Dopo l'ingresso pubblico del brand tramite `BrandDomain`, lo step 0008 ha definito la home standard del brand quando non esiste una `home_page_key` custom.

## Scelte fissate

- il dominio brand senza `home_page_key` resta sulla root `/`
- la root pubblica standard del brand non redirige piu' a `/ports/:id/public`
- il primo livello pubblico del brand viene letto dalle `SeaRoute` uscenti dal `BrandPort`
- l'ordine del primo livello vive su `SeaRoute.position`
- la direzione reale della rotta vive in `source_port_id -> target_port_id`
- `bidirectional:boolean` rappresenta lo stato neutro

## Attuazione

Sono state attuate queste modifiche:

- layout pubblico brand dedicato, separato dal guscio FlowPulse standard
- home standard del brand renderizzata direttamente sulla root del dominio
- nav pubblico brand semplificato:
  - logo a sinistra
  - voci menu semplici dal primo livello pubblico
  - area destra con `Iscriviti` e `Accedi` se anonimo
  - dropdown profilo minimale con `Profilo` e `Esci` se autenticato
- carta nautica creator allineata al nuovo modello delle rotte:
  - `bidirectional`
  - inversione reale di `source_port_id` e `target_port_id`
  - selezione direzione via dropdown
- blocco dei duplicati `SeaRoute` tra gli stessi due `Port` anche con verso invertito

## Outcome

Alla chiusura dello step 0008 il sistema consente:

- una home standard del brand coerente col dominio pubblico
- un nav semplice basato sui `Port` di primo livello
- un primo livello ordinabile sulle `SeaRoute`
- una separazione pulita tra struttura del grafo e resa grafica della direzione
