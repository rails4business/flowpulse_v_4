# Planning Develop Step 0004

## Stato

Completato.

## Stato attuale

Lo step 0003 ha chiuso il primo impianto del mare:

- `Port`
- carta nautica creator
- coordinate `x,y`
- per ora tutto mare

## Step attuale

si deve sistemare la parte grafica di:

http://localhost:3000/creator/carta_nautica?add_port=true&x=284&y=99

Si dovrebbe creare un port quando clicchi al posto di:

http://localhost:3000/creator/carta_nautica?add_port=true&x=284&y=99

e aprire un modal in centro alla pagina per inserire i dati del port:

Ma il punto che poi dvorebbe comparire il simbolo pattuito in base al tipo di enum

enum :port_kind, { brand: 0, map_port: 1, blog: 2, book: 3 }

e sulla mappa dovrebbe restare come segnaposto, un port dovrebbe essere o un brand o appartenere a un brand oppure può essere un brand e appartenere a un brand.

## User experience

Carta nautica poter cliccare e creare un port, scegliere il tipo di port, inserire nome e descrizione, salvare e vedere il port sulla mappa con il simbolo corrispondente al tipo scelto.
Il port dovrebbe essere salvato con le coordinate x e y del punto cliccato sulla mappa.

## Logica usata

### Regola di accesso

Solo un creator approvato manualmente puo' usare la carta nautica creator e creare `Port`.

Questo significa:

- non basta essere autenticati
- non basta avere un `Profile`
- il profilo deve risultare `creator?`
- l'abilitazione creator non nasce in automatico durante registrazione o creazione profilo
- l'approvazione creator resta una decisione manuale di admin/superadmin

### Regola di appartenenza

La mappa del creator e' formata da tutti i `Port` appartenenti al suo `Profile`.

In pratica:

- la carta nautica legge `Current.session.user.profile.ports`
- ogni `Port` creato viene sempre salvato dentro `Current.session.user.profile.ports.new(...)`
- un creator non crea port "nel sistema in generale"
- crea solo port nella propria carta nautica

### Flusso UX fissato nello step 0004

Il flusso operativo previsto e' questo:

1. il creator approvato apre `creator/carta_nautica`
2. clicca `+ Porto`
3. la mappa entra in add mode
4. il click sul mare calcola `x,y`
5. si apre un modal centrale con il form del nuovo `Port`
6. il form salva:
   - tipo
   - nome
   - slug
   - descrizione
   - eventuale brand di appartenenza
   - coordinate `x,y`
7. dopo il salvataggio il `Port` compare nella carta nautica del creator
8. il simbolo visivo dipende da `port_kind`

### Scelte implementative aggiunte

- il modal viene renderizzato direttamente nella pagina della carta nautica, cosi' errori di validazione e stato del form restano nello stesso contesto
- la chiusura del modal riporta alla carta nautica pulita, evitando di lasciare il flag `add_port=true` aperto in modo ambiguo
- il modello `Port` genera lo slug dal nome se manca
- `x` e `y` sono validate come coordinate intere
- `color_key` e' gestito sul `Port` tramite input colore e applicato alla resa del nodo
- il porto usa il proprio colore come identita' interna
- l'appartenenza a un `brand_port` viene mostrata tramite bandiera colorata del brand
- la carta nautica ha ricevuto una resa grafica piu' evocativa del mare e dei porti, con sfondo leggero e nodi trattati come piccole isole/approdi

## Outcome raggiunto

Lo step 0004 ha chiuso:

- flusso `+ Porto` -> click sulla mappa -> modal -> salvataggio
- salvataggio delle coordinate `x,y`
- accesso riservato al creator approvato manualmente
- mappa del creator come insieme dei `Port` del suo `Profile`
- distinzione visiva dei `Port` tramite tipo, colore e appartenenza al brand
- prima identita' grafica della carta nautica creator

### Nota sui test

Nei test non va simulata una "approvazione automatica" del creator in fase di creazione profilo.

Per questo i test aggiornati verificano prima di tutto la regola di blocco:

- se il profilo non e' creator approvato, le route creator sono respinte
- quindi l'accesso alla carta nautica e la creazione di `Port` restano protetti dal vincolo manuale

## File modificati

### Logica applicativa

- [`app/models/port.rb`](../../../app/models/port.rb)
- [`app/controllers/creator/ports_controller.rb`](../../../app/controllers/creator/ports_controller.rb)
- [`app/views/creator/carta_nautica.html.erb`](../../../app/views/creator/carta_nautica.html.erb)
- [`app/views/creator/ports/_form.html.erb`](../../../app/views/creator/ports/_form.html.erb)
- [`app/views/creator/ports/new.html.erb`](../../../app/views/creator/ports/new.html.erb)
- [`app/views/creator/ports/_modal.html.erb`](../../../app/views/creator/ports/_modal.html.erb)
- [`app/javascript/controllers/port_modal_controller.js`](../../../app/javascript/controllers/port_modal_controller.js)

### Test aggiornati

- [`test/controllers/creator_controller_test.rb`](../../../test/controllers/creator_controller_test.rb)
- [`test/controllers/creator/ports_controller_test.rb`](../../../test/controllers/creator/ports_controller_test.rb)
- [`test/models/port_test.rb`](../../../test/models/port_test.rb)
