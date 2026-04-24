# planning_develop_step_0016.md

## Focus

Lo `0016` apre il passaggio dalla sola metro map editoriale a una struttura piu' forte di percorso.

I punti da fissare qui sono:

- `Station` che puo' aprire anche un `Port`
- fine di una `Line` che puo' portare a piu' linee successive
- distinzione piu' chiara tra:
  - struttura del percorso
  - contenuto/programma dell'esperienza
- albero delle `Experience`

Lo step non deve ancora risolvere tutto il `Journey`.

Prima deve chiarire come si aprono:

- bivi
- passaggi di porto
- ramificazioni di experience

## Stato Di Partenza

La base dati attuale resta:

- `Port`
- `Line`
- `Experience`
- `Station`

Con queste regole gia' vive:

- `Line belongs_to :port`
- `Experience belongs_to :port`
- `Station belongs_to :line`
- `Station belongs_to :experience`
- `Station` puo' avere:
  - `link_station_id`
  - `link_port_id`
  - `map_x`
  - `map_y`

La `land_map` creator ora funziona abbastanza da:

- creare una `Line`
- creare la prima `Station`
- aggiungere station successive
- selezionare il contesto nella mappa

## Correzione Del Modello Station

Lo `0016` deve fissare una distinzione che oggi nel modello non e' ancora pulita:

- il ruolo della station nel percorso
- il tipo del nodo nella rete

Queste due dimensioni non sono la stessa cosa.

### Ruolo Della Station Nel Percorso

Qui rientra la posizione narrativa o sequenziale della station:

- `opening`
- `step`
- `closing`

Questo asse dice:

- se la station apre il percorso
- se e' una tappa interna
- se e' una chiusura della line

### Tipo Del Nodo Nella Rete

Qui rientra il modo in cui la station si comporta nella struttura:

- `normal`
- `branch`
- `gate`

Questo asse dice:

- se il nodo e' normale
- se apre un ramo
- se apre un passaggio o una porta verso un altro contesto

### Conseguenza

Una station deve poter combinare le due cose.

Per esempio:

- una station puo' essere `opening` e insieme `gate`
- una station puo' essere `closing` e insieme `branch`
- una station puo' essere `step` e insieme `gate`

Quindi `opening/closing` non devono stare nello stesso enum di `branch/gate`.

## Entry Station Del Port

Va fissato anche che un `Port` non si apre "sulla line" in astratto.

Si apre da una o piu' station iniziali primarie.

Quindi:

- un `Port` deve poter avere una o piu' `entry station`
- quelle station sono i veri ingressi del port
- da quelle station poi partono una o piu' linee

### Conseguenza Pratica

Quando un utente entra in un `Port`:

- non atterra direttamente su una line generica
- atterra su una entry station primaria del port
- da li' inizia il percorso

Questo vale anche per port con piu' ingressi:

- il port puo' avere piu' entry station
- ognuna puo' aprire un percorso diverso

### Implementazione Pragmatica Attuale

Per ora questo punto non richiede un model dedicato.

La scelta pragmatica e':

- aggiungere su `Station` un boolean `port_entry`

Significato:

- `true`
  - questa station e' un ingresso del port
- `false`
  - station normale

Questo attributo non va confuso con:

- `opening/step/closing`
- `normal/branch/gate`

Perche' `port_entry` non e' un tipo di nodo.
E' una proprieta' aggiuntiva della station.

## Punto 1

### una `Station` puo' anche aprire un `Port`

Questo punto non va piu' trattato come eccezione.

Va fissato che:

- una `Station` puo' rappresentare una tappa interna della `Line`
- ma puo' anche essere un punto che porta a un altro `Port`

Quindi `link_port_id` non e' solo un dettaglio tecnico.

E' uno dei modi veri in cui il percorso puo':

- cambiare contesto
- uscire da una line
- aprire un nuovo spazio di percorso

### Obiettivo

Far leggere nella mappa e nel dominio che:

- una station puo' essere
  - tappa interna
  - uscita verso un altro port

## Punto 2

### la fine di una `Line` puo' aprire piu' linee

Questo serve per la scelta del viaggiatore.

La logica da fissare e':

- una line non deve per forza finire in modo chiuso e lineare
- alla fine puo' aprirsi un bivio
- da quel bivio il viaggiatore potra' prendere una strada diversa
- questa scelta influenzera' poi il suo `Journey`

Per ora non serve ancora implementare tutto il `Journey`.

Serve prima chiarire il modello di uscita:

- una `Station` finale puo' collegarsi a piu' linee successive

### Conseguenza

Il solo `link_station_id` non basta piu' come modello definitivo.

Nel breve puo' bastare ancora per prototipare.

Ma lo `0016` deve segnare che il modello target va verso:

- collegamenti multipli tra nodi
- oppure un model di transizione dedicato

Questo punto non va ancora forzato in migration subito.

Va prima fissato bene nel dominio.

### Chiarimento operativo sui collegamenti tra station

Nel dominio attuale il punto vero non e' "solo la fine della line".

Il punto vero e':

- una `Station` puo' collegarsi a un'altra `Station`
- questo puo' succedere anche tra linee diverse
- il collegamento puo' partire anche da una station intermedia

Quindi casi validi sono:

- la terza station di una line che si collega alla seconda station di un'altra line
- una nuova line che nasce da una station intermedia di una line gia' esistente
- una station finale che apre una line successiva

### Regola pragmatica attuale

Per ora `link_station_id` puo' ancora bastare se lo leggiamo cosi':

- la station corrente punta alla station sorgente da cui si innesta

In pratica:

- la station nuova tiene memoria della station da cui arriva
- il collegamento e' orientato
- la direzione e' parte del significato del nodo

Questa regola consente gia':

- innesti tra linee
- ramificazioni da station intermedie
- continuazioni non solo da capolinea

### Station principale e station di collegamento

Per evitare ambiguita' conviene fissare anche questa distinzione:

- la station linkata da `link_station_id` e' la station principale
- la station corrente e' la station di collegamento o station innestata

Quindi:

- la station principale resta il nodo canonico del punto di passaggio
- la station principale porta il contenuto principale
- la station di collegamento non ha una experience propria autonoma
- la station di collegamento fa capo alla station principale

Nel modello pragmatico attuale questo significa:

- la nuova line non condivide ancora lo stesso record station
- crea la sua station
- quella station punta alla station principale tramite `link_station_id`
- la experience canonica resta sulla station principale

### Conseguenza pratica

Per lo `0016` la lettura corretta diventa:

- `link_station_id` significa: questa station si innesta su quella station
- la station principale puo' stare all'inizio, in mezzo o alla fine di una line
- la station di collegamento serve al tracciato della nuova line
- il contenuto resta centrato sulla station principale

### Dominio e UI

La station di collegamento va distinta anche tra dominio e interfaccia:

- nel dominio esiste davvero
- nel builder creator puo' essere visibile
- nella UI normale deve emergere soprattutto la station principale

Quindi:

- la station principale e' il nodo reale del percorso
- la station di collegamento e' soprattutto un nodo tecnico di innesto
- il journey deve leggere il passaggio dalla station principale
- la station di collegamento non deve apparire come nuova tappa autonoma del contenuto

### Allineamento schema

Se la station di collegamento non deve avere una experience propria, allora anche lo schema deve
riflettere questa regola:

- `stations.experience_id` deve poter essere `NULL`
- il vincolo di presenza della experience resta sulle station principali a livello di model

### Nodo di scelta del percorso

La station principale non e' solo il nodo canonico del contenuto.

E' anche il punto in cui il percorso puo' decidere come proseguire.

Da una station principale possono quindi aprirsi tre direzioni:

- proseguire sulla stessa `Line`
- cambiare `Line`
- uscire dal `Port` attuale ed entrare in un altro `Port`

Quindi:

- la scelta del viaggio sta sulla station principale
- la station di collegamento serve solo a dare binario alla line che si innesta
- `link_port_id` va letto come uscita dal port corrente e ingresso in un altro port

### Modalita' di creazione di una nuova line

Per evitare ambiguita' nel builder, conviene fissare tre casi distinti:

- nuova line da punto vuoto
- nuova line da station principale selezionata
- nuova line da station di collegamento selezionata

#### 1. Nuova line da punto vuoto

- il creator clicca `Aggiungi line`
- poi clicca un punto vuoto della mappa
- nasce una line autonoma
- la prima station della line e' una station principale

Quindi:

- ha una `experience`
- non ha `link_station_id`

#### 2. Nuova line da station principale selezionata

- il creator seleziona una station principale
- clicca `Aggiungi line`
- poi clicca il punto in cui vuole far partire il nuovo tracciato

Quindi:

- nasce una nuova line innestata
- la prima station della nuova line e' una station di collegamento
- `link_station_id` punta alla station principale selezionata
- `experience_id` della prima station resta `NULL`

#### 3. Nuova line da station di collegamento selezionata

- il creator puo' cliccare anche una station di collegamento
- ma quella station non diventa il nodo canonico del nuovo innesto

La regola corretta e':

- il sistema risolve automaticamente la `primary_station`
- la nuova line si innesta sulla station principale
- non si creano innesti tecnici sopra altri innesti tecnici

### Builder creator

Nel builder conviene anche fissare due regole di UX:

- la top bar della `land_map` deve restare compatta
- quando entri in `Modifica`, `Nuova line` deve essere disponibile subito come azione globale

Inoltre:

- il modal `Modifica station` deve permettere di sganciare un `link_station`
- il modal `Modifica station` deve permettere di sganciare un `link_port`

### Preselezione sulla mappa durante il piazzamento

Nel builder, sia `new_line` sia `new_station` devono usare la stessa grammatica visiva:

- se il cursore passa vicino a una station esistente, quella station si preseleziona
- se il creator clicca li', la nuova line o la nuova station partono da quel nodo
- se il creator clicca su un punto vuoto, il nuovo nodo nasce su un punto libero della mappa

Quindi la differenza tra:

- partenza da station esistente
- partenza da punto vuoto

non deve essere affidata solo al modal finale, ma deve emergere gia' dal comportamento del cursore sulla mappa.

### Principi grafici della metro map

La mappa terra deve restare prima di tutto una mappa, non una lista travestita.

Per questo conviene fissare queste regole:

- il nome delle `Line` non deve stare sempre sopra il tracciato
- il nome delle `Line` va soprattutto nella legenda o nel pannello laterale
- sulla mappa il nome della `Line` puo' emergere solo quando la line e' selezionata

Inoltre:

- il tracciato tra station e station deve essere piu' sottile
- le station normali devono restare semplici e compatte
- quando selezioni una line o una station, il nodo puo' ingrandirsi leggermente

### Station condivise e station tecniche

Le station condivise o di collegamento non devono sembrare una fermata normale.

Conviene fissare questa direzione:

- la station normale resta un nodo semplice
- la station condivisa o tecnica va resa come un giunto
- visivamente puo' essere piu' vicina a un rettangolo con lati arrotondati
- il segno deve riassumere l'idea di sottopassaggio, connessione o nodo condiviso

Quindi:

- non va trattata come una fermata di contenuto
- non deve usare lo stesso linguaggio pieno delle station principali
- deve farsi leggere come infrastruttura del percorso

### Shared station group nella mappa

Nel dominio possono continuare a esistere:

- una station principale
- una o piu' station con `link_station_id` verso quella principale

Ma nella mappa queste station devono poter apparire come un solo nodo condiviso.

La regola corretta e':

- la mappa costruisce un gruppo `primary + linked stations`
- il gruppo viene disegnato con un contorno unico
- le singole station interne restano comunque selezionabili

Quindi:

- il contorno unico comunica il nodo condiviso
- i nodi interni mantengono l'identita' delle singole line
- il builder puo' selezionare:
  - il gruppo come forma visiva
  - oppure una singola station come record operativo

### Principi di editing della line

Una `Line` non deve biforcarsi al suo interno come sotto-linea implicita.

Quindi:

- se selezioni una line o una station di quella line
- `Aggiungi station` deve aggiungere sulla prosecuzione finale della line
- non deve creare una biforcazione interna della stessa line

Questo significa:

- se selezioni una station finale, la nuova station continua la line
- se selezioni una station intermedia, la nuova station non apre una deviazione autonoma della stessa line

### Caso della station intermedia

Se il creator parte da una station intermedia di una line e usa `Aggiungi station`, la regola proposta e':

- la nuova station non genera una sottolinea
- il posizionamento va risolto in modo coerente col tracciato esistente
- nel caso minimo, puo' essere piazzata automaticamente tra le station vicine del segmento

Questa pero' e' una regola di emergenza per non rompere la line.

La regola piu' forte resta:

- la continuazione normale di una line nasce dal suo nodo finale
- se vuoi aprire un nuovo ramo da una station intermedia, devi usare `Aggiungi line`

### Comportamento operativo di `Aggiungi station`

Per il builder conviene fissare questa regola concreta:

- se il creator aggancia una station finale, `Aggiungi station` prolunga la line
- se il creator aggancia una station intermedia, `Aggiungi station` inserisce un nuovo nodo nel segmento successivo della stessa line

Quindi:

- non nasce una sottolinea
- non nasce una deviazione implicita
- la nuova station viene inserita nell'ordine della line

Nel caso di station intermedia:

- la nuova station va posizionata automaticamente a meta' tra la station selezionata e la station successiva
- le `position` successive vanno riallineate per lasciare spazio al nuovo nodo

### Flusso esplicito di `new_station`

Per rendere chiaro l'inserimento nella stessa line, `Aggiungi station` deve partire da una sola scelta esplicita.

#### Scelta di relazione con la station selezionata

Quando il creator clicca una station e sceglie `Aggiungi station`, deve prima dichiarare:

- `Prima`
- `Dopo`

Questa scelta dice da quale lato del nodo selezionato verra' inserita la nuova station.

#### Risoluzione automatica del posizionamento

Dopo `Prima/Dopo`, il sistema non deve piu' chiedere anche `Posiziona libera / Inserisci nel segmento`.

La regola corretta e':

- se sul lato scelto esiste gia' una station adiacente
  - la nuova station viene inserita automaticamente nel segmento tra le due
- se sul lato scelto non esiste una station adiacente
  - la nuova station viene piazzata liberamente sulla mappa usando il puntatore

### Regole risultanti

- prima station della line + `Prima`
  - nuova station libera prima della prima station
- station intermedia + `Prima`
  - nuova station inserita tra la precedente e quella selezionata
- station intermedia + `Dopo`
  - nuova station inserita tra la selezionata e la successiva
- ultima station della line + `Dopo`
  - nuova station libera dopo l'ultima station

### Effetto nel builder

Quando la nuova station va inserita automaticamente tra due station gia' esistenti:

- la mappa non deve aspettare un altro click
- deve calcolare subito il punto medio del segmento
- deve aprire direttamente il modal della nuova station

Il click sulla mappa resta necessario solo nei casi liberi:

- prima della prima station
- dopo l'ultima station

### Vincolo strutturale

Questo flusso vale solo per la stessa line.

Se il creator vuole aprire un nuovo ramo da una station:

- non usa `Aggiungi station`
- usa `Aggiungi line`

### Ordine e priorita' delle uscite

Quando una station principale apre piu' possibilita', lo `0016` non introduce ancora
un model dedicato di transizione.

Per ora conviene tenere la regola semplice:

- la station principale e' il nodo da cui si leggono le uscite possibili
- l'ordine delle uscite resta implicito nella struttura esistente
- la priorita' non viene ancora modellata come campo autonomo

In pratica, per il passo attuale:

- la prosecuzione sulla stessa `Line` resta la lettura piu' naturale
- le line che si innestano tramite `link_station_id` sono alternative che partono da quel nodo
- il passaggio a un altro `Port` tramite `link_port_id` e' un'altra uscita possibile

## Backlog UI Builder

Da tenere segnati ma non mischiare con la logica appena chiusa:

- station normali:
  - usare pallino bianco come linguaggio base
- station condivise / tecniche:
  - non vanno disegnate come station separate
  - la mappa deve collassare:
    - station principale
    - station di collegamento
    - eventuali altre station agganciate
    in un unico nodo condiviso
  - quel nodo condiviso deve avere una sola forma visiva, non una somma di fermate duplicate
  - la forma va poi progettata come giunto/sottopassaggio, ma solo dopo aver unificato il gruppo a livello dati
- intersezione con station di altre line:
  - la preselezione sotto il cursore oggi non e' abbastanza chiara
  - va evidenziata meglio quando si vuole intersecare un nodo di un'altra line
  - nei casi liberi di `Nuova station`, se il cursore passa su una station di un'altra line:
    - la mappa deve leggerlo come ampliamento del gruppo condiviso
    - non come semplice punto libero
- drag in edit mode:
  - quando `Modifica` e' attivo, le station dovranno poter essere trascinate

### Passo tecnico corretto per le station condivise

Prima di rifare la forma grafica, il builder deve introdurre il concetto di gruppo condiviso:

- una station principale
- tutte le station che la referenziano tramite `link_station_id`

La mappa deve usare questo gruppo come unita' di render:

- un solo nodo visivo
- piu' appartenenze di line
- un solo punto canonico di lettura

Questa e' la base necessaria per evitare che le station condivise sembrino fermate duplicate.

### Conseguenza progettuale

Finche' non serve un vero motore di scelta, il sistema puo' leggere il nodo cosi':

- arrivo sulla station principale
- vedo le continuazioni possibili
- scelgo se:
  - restare sulla line
  - cambiare line
  - uscire dal port

Se in seguito servira':

- ordinare esplicitamente le uscite
- dare priorita' diverse
- nascondere o attivare certe uscite in base al journey

allora andra' introdotto un model dedicato di transizione o uscita.

### Limite noto

`link_station_id` resta comunque una scorciatoia.

Regge bene finche':

- ogni station ha un solo aggancio principale
- la direzione e' letta come "questa station nasce da quella station"

Se piu' avanti servira':

- una station con piu' ingressi o piu' uscite modellate esplicitamente
- metadata sui collegamenti
- tipi di transizione

allora andra' introdotto un model di transizione dedicato.

Per lo `0016`, pero', la decisione pragmatica resta:

- tenere `link_station_id`
- fissarne bene la semantica direzionale

## Punto 3

### `blog`, `book`, `course` non stanno bene come tipi di `Line`

La direzione proposta e' corretta:

- `blog`
- `book`
- `course`

sono piu' vicini a un modo di organizzare o consumare le `Experience`
che non al binario puro della line.

Quindi nel `0016` si fissa questa idea:

- la `Line` resta struttura di percorso
- il "modo" editoriale/didattico va piu' vicino a `Experience`

### Stato attuale sugli enum

Questo spostamento e' stato aperto anche nel codice.

Direzione attuale:

- `Line.line_kind`
  - `trail`
  - `branch`
  - `folder`
  - `route`
- `Experience.experience_kind`
  - `lesson`
  - `program`
  - `quiz`
  - `blog`
  - `book`
  - `course`
  - `exercise`
  - `page`
  - `video`
  - `sheet`

Nota:

- per `Line` i vecchi valori editoriali vengono ricondotti a tipi piu' neutri
- per `Experience` i tipi editoriali e didattici vengono ampliati

### Direzione proposta per gli enum

`Line` va alleggerita verso tipi piu' strutturali.

`Experience` va ampliata verso tipi piu' editoriali e didattici.

Direzione target:

- `Line`
  - `trail`
  - `branch`
  - `folder`
  - eventualmente un tipo piu' neutro di default

- `Experience`
  - `lesson`
  - `program`
  - `quiz`
  - `blog`
  - `book`
  - `course`
  - altri tipi operativi se serviranno

### Prima proposta

Tenere `Line` il piu' neutra possibile come struttura:

- binario
- sequenza
- ramo
- trail

e spostare invece sui contenuti/experience il concetto di:

- `lesson`
- `program`
- `quiz`
- `blog`
- `book`
- `course`

### Nota

Questo non obbliga a migrare subito tutto.

Ma evita di caricare `Line` di significati editoriali troppo diversi.

## Punto 4

### `Experience` deve poter crescere ad albero

Qui la proposta forte e' buona:

- `Experience` puo' avere `parent_experience_id`
- `Experience` puo' avere `position`

Questo permette:

- moduli composti
- sottopassi
- lesson annidate
- programmi ramificati
- quiz dentro un percorso piu' grande

### Regola

La mappa principale resta:

- `Line`
- `Station`

Ma la `Experience` aperta da una station puo' avere sotto di se':

- altre experience
- ordinate
- annidate

Quindi:

- la mappa resta leggibile
- l'interno del nodo puo' diventare piu' ricco

### Primo passaggio operativo

Il primo passaggio concreto dello `0016` parte da qui:

- aggiungere `parent_experience_id` a `Experience`
- riusare `position` come ordinamento dei figli
- esporre subito il parent nel CRUD creator

Questo permette di iniziare a costruire l'albero senza toccare ancora:

- `Journey`
- bivi multipli tra station
- migration degli enum

## Punto 5

### gemma / albero

La "gemma" per l'albero non va ancora fissata come implementazione obbligatoria.

Pero' il concetto va segnato:

- quando una `Experience` ha figli
- deve esistere una vista ad albero
- o comunque una vista di ramo

Questo puo' diventare:

- una piccola gemma UI
- una tree view
- una lista annidata

Il punto importante ora non e' la gemma.

E' che il modello supporti davvero l'albero.

## Punto 6

### relazione di `Journey` ed `Event` con `Port`, `Line`, `Station`

Il quadro che hai descritto va fissato cosi':

- un `Journey` puo' nascere da un `Port`
- oppure puo' nascere da una `Line`
- poi si muove passando per `Station`
- una `Station` puo':
  - proseguire dentro la stessa line
  - aprire un bivio verso altre line
  - aprire un altro port

Quindi:

- `Journey` non va pensato solo come "istanza di una line"
- va pensato come cammino reale della persona dentro:
  - port
  - line
  - station
  - passaggi tra contesti

### ruolo di `Event`

`Event` va letto come tappa concreta nel tempo del `Journey`.

Quindi:

- `Journey` = percorso vivo della persona
- `Event` = passaggio concreto, fatto, incontro, attivazione

L'`Event` potra' poi agganciarsi a:

- `Port`
- `Line`
- `Station`
- `Experience`

ma nel `0016` non va ancora modellato tutto.

Qui basta fissare la direzione:

- il `Journey` attraversa la struttura
- l'`Event` registra cosa succede davvero lungo quel cammino

## Punto 7

### cosa aggiungere davvero prima del `Journey`

Prima di formalizzare `Journey` e `Event`, il minimo da aggiungere/chiarire e':

- un modello di uscita multipla da `Station`
  - non basta piu' solo `link_station_id`
- `parent_experience_id` su `Experience`
- `position` su `Experience`
- una distinzione piu' pulita tra:
  - `line_kind`
  - `experience_kind`

### target minimo di modello

Il minimo che conviene fissare adesso e':

- `Station`
  - resta nodo della mappa
  - puo' puntare a un `Port`
  - puo' avere piu' uscite future
- `Experience`
  - ha `experience_kind`
  - ha `parent_experience_id`
  - ha `position`

### punto aperto

Il vero punto ancora aperto e':

- come modellare i bivi multipli

Le strade candidate sono due:

1. tenere per poco `link_station_id` e aggiungere poi una join
2. introdurre gia' un model di transizione tra station

La mia raccomandazione resta:

- prima fissare bene il dominio
- poi scegliere il model tecnico

## Ordine Di Lavoro Consigliato

1. fissare che `Station` puo' portare a un `Port`
2. fissare che una fine line puo' aprire piu' linee
3. discutere se `Line` va alleggerita dai tipi `blog/book/course`
4. introdurre `parent_experience_id` e `position` su `Experience`
5. chiarire il ruolo minimo di `Journey` ed `Event`
6. solo dopo riprendere il pezzo `Journey` come model vero

## Decisione Pragmatica

La mia raccomandazione netta e':

- non toccare ancora il `Journey`
- prima chiarire bene:
  - nodi
  - bivi
  - passaggi di porto
  - albero delle experience

Perche' il `Journey` ha senso solo quando il sistema sa gia':

- da dove si esce
- dove si biforca
- cosa c'e' dentro ogni nodo

## Criterio Di Chiusura Dello Step

Lo `0016` si puo' chiudere quando sono chiari questi quattro punti:

- `Station -> Port`
- uscite multiple di `Line`
- ruolo vero di `Line` rispetto a `blog/book/course`
- `Experience` con `parent_experience_id` e `position`

e quando e' chiaro anche questo:

- da dove nasce il `Journey`
- come attraversa `Port`, `Line`, `Station`
- dove si appoggia poi l'`Event`
