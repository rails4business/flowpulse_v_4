# Planning Develop Step 0005

## Dopo il livello terra

Prima va chiarito bene il livello della terra:

- `Trail`
- `Service`
- `Event`
- `Activity`
- contenuti e materiali

- `SeaRoute`

## Focus previsto

- introdurre `SeaRoute` come collegamento tra `Port`
- capire se le rotte sono semplici o orientate
- capire se una rotta ha solo origine/destinazione o anche punti intermedi
- definire come la carta nautica del creator passa da insieme di porti a rete navigabile
- capire come il viaggiatore puo' attraversare carte gia' disegnate senza crearle

## Punto centrale

La domanda vera dello step 0005 sara':

come collegare i `Port` senza tornare a un modello ad albero?

## Da chiarire

- struttura minima di `SeaRoute`
- rapporto tra `Port` e `SeaRoute`
- relazione tra rotte nautiche e `Trail`
- impatto su home e about

## Reference

- step attuale:
  - `doc/steps/todo/planning_develop_step_0004.md`

# Planning Develop Step 0006

## Stato

## Punto di partenza

'idea corretta di prosecuzione non e' aggiungere tante varianti alla carta nautica, ma far si' che un `Port` possa diventare punto di ingresso verso un percorso pratico a terra.

## Focus del passo

Questo step deve introdurre il primo ponte operativo tra:

- `Port`
- `Trail`
- `Service`

Questo lo si vede nella view show del port

In termini concreti:

- un `Port` non e' piu' solo un nodo della mappa del mare
- un `Port` puo' diventare accesso a un percorso reale
- il creator puo' iniziare a costruire continuita' tra arrivo via mare e sviluppo a terra

Lo step ha chiuso la rete minima del mare:

- esistono i `Port`
- esistono le `SeaRoute`
- la carta nautica del creator e' diventata navigabile

Ora il punto non e' complicare ancora il mare.

Il punto e' iniziare il passaggio tra:

- mare
- terra

## Domanda centrale

Come si passa da un `Port` navigabile a un percorso pratico vissuto senza confondere:

- struttura
- contenuto
- servizio
- esperienza concreta

## Focus dello step 0006

Questo step deve iniziare a chiarire il livello terra minimo, partendo da:

- `Trail`
- rapporto tra `Port` e `Trail`
- primi agganci con `Service`

## Ipotesi iniziale

Direzione proposta:

- `Port` resta nodo del mare
- `SeaRoute` resta collegamento del mare
- `Trail` entra come percorso della terra

Quindi:

- il mare organizza e orienta
- la terra fa vivere l'esperienza

## Cosa decidere qui

- struttura minima di `Trail`
- se `Trail` nasce da un `Port` oppure vi si collega soltanto
- differenza minima tra `Trail` e `Service`
- quali `Port` possono aprire un `Trail`
  - probabilmente soprattutto i `map_port`

## Outcome atteso

Alla fine dello step 0006 devono essere chiari:

- il significato minimo di `Trail`
- il legame corretto tra `Port` e `Trail`
- il primo confine tra mare e terra
- il punto in cui poi potra' entrare `Service`
