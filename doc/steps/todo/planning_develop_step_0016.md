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
